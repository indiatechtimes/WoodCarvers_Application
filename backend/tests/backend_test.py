"""Comprehensive WOOD CARVERS rebrand API, CRUD, authorization, checkout, and regression tests."""
import re
import uuid
from io import BytesIO
from pathlib import Path

import pytest
import requests
from PIL import Image
from dotenv import dotenv_values

frontend_env = dotenv_values("/app/frontend/.env")
BASE_URL = (frontend_env.get("REACT_APP_BACKEND_URL") or "").rstrip("/")
if not BASE_URL:
    raise RuntimeError("REACT_APP_BACKEND_URL is missing from /app/frontend/.env")

ALLOWED_CATEGORIES = {"wall-decor", "home-decor", "kitchen", "office", "gifts", "personalized"}
LEGACY_CATEGORIES = {"bamboo-decor", "leaf-decor", "wall-art", "lamps", "planters", "baskets"}


def assert_success(response, status=200):
    assert response.status_code == status, response.text
    data = response.json()
    assert data.get("success") is True, data
    return data


def headers(auth):
    return {"Authorization": f"Bearer {auth['accessToken']}"}


@pytest.fixture(scope="session")
def client():
    session = requests.Session()
    session.headers.update({"Accept": "application/json"})
    return session


@pytest.fixture(scope="session")
def admin_credentials():
    path = Path("/app/memory/test_credentials.md")
    if not path.exists():
        pytest.skip("Missing /app/memory/test_credentials.md")
    text = path.read_text(encoding="utf-8")
    email = re.search(r"(?im)^- Email:\s*`([^`]+)`", text)
    password = re.search(r"(?im)^- Password:\s*`([^`]+)`", text)
    if not email or not password:
        pytest.skip("Admin email/password missing from test_credentials.md")
    return {"email": email.group(1), "password": password.group(1)}


@pytest.fixture(scope="session")
def admin(client, admin_credentials):
    data = assert_success(client.post(f"{BASE_URL}/api/auth/login", json=admin_credentials))
    assert data["user"]["email"] == admin_credentials["email"]
    assert data["user"]["role"] == "admin"
    assert "password" not in data["user"] and "refreshTokens" not in data["user"]
    return data


@pytest.fixture(scope="session")
def user(client):
    suffix = uuid.uuid4().hex[:10]
    payload = {
        "name": f"TEST Wood Carvers {suffix}",
        "email": f"test_wc_{suffix}@example.test",
        "password": "TestPass123!",
    }
    data = assert_success(client.post(f"{BASE_URL}/api/auth/register", json=payload), 201)
    assert data["user"]["email"] == payload["email"]
    assert data["user"]["role"] == "user"
    assert "password" not in data["user"] and "refreshTokens" not in data["user"]
    data["credentials"] = payload
    return data


@pytest.fixture(scope="session")
def catalog(client):
    return assert_success(client.get(f"{BASE_URL}/api/products?limit=100"))["products"]


class TestSeedAndPublicCatalog:
    """Seed sanity, related products, settings, filters, and public coupon validation."""

    def test_exactly_twelve_new_category_products(self, catalog):
        assert len(catalog) == 12
        assert {p["category"] for p in catalog}.issubset(ALLOWED_CATEGORIES)
        assert {p["category"] for p in catalog}.isdisjoint(LEGACY_CATEGORIES)
        assert {p["category"] for p in catalog} == ALLOWED_CATEGORIES
        assert len({p["slug"] for p in catalog}) == 12
        assert all(p["brand"] == "WOOD CARVERS" for p in catalog)

    def test_nameplate_seed_image_resolves(self, client):
        data = assert_success(client.get(f"{BASE_URL}/api/products/engraved-wooden-name-plate"))
        product = data["product"]
        assert product["slug"] == "engraved-wooden-name-plate"
        assert product["media"] and product["media"][0]["type"] == "image"
        image_url = product["media"][0]["url"]
        assert "photo-1607083208316-ea7b2c8e5c31" not in image_url
        image = client.get(image_url, timeout=30)
        assert image.status_code == 200, f"Seed image failed: {image.status_code} {image_url}"
        assert image.headers.get("Content-Type", "").startswith("image/")
        assert len(image.content) > 1000
        with Image.open(BytesIO(image.content)) as decoded:
            assert decoded.width > 0 and decoded.height > 0

    def test_walnut_detail_has_same_category_related(self, client):
        data = assert_success(client.get(f"{BASE_URL}/api/products/walnut-sunburst-wall-art"))
        product, related = data["product"], data["related"]
        assert product["slug"] == "walnut-sunburst-wall-art"
        assert product["category"] == "wall-decor"
        assert isinstance(related, list) and 0 < len(related) <= 4
        assert all(p["category"] == product["category"] and p["_id"] != product["_id"] for p in related)

    def test_settings_shape(self, client):
        settings = assert_success(client.get(f"{BASE_URL}/api/settings"))["settings"]
        assert {"hero_image", "hero_headline", "hero_subheading", "promo_banner", "logo_url"}.issubset(settings)
        assert settings["hero_headline"] == "Handcrafted Elegance for Every Home"
        assert isinstance(settings["promo_banner"], dict)
        assert isinstance(settings["promo_banner"]["active"], bool)
        assert isinstance(settings["promo_banner"]["text"], str) and settings["promo_banner"]["text"]

    @pytest.mark.parametrize(
        "params,predicate",
        [
            ({"category": "office"}, lambda p: p["category"] == "office"),
            ({"minPrice": 3000, "maxPrice": 4999}, lambda p: 3000 <= p["price"] <= 4999),
            ({"minRating": 4.5}, lambda p: p["rating"] >= 4.5),
            ({"inStock": "true"}, lambda p: p["stock"] > 0),
        ],
    )
    def test_product_filters(self, client, params, predicate):
        data = assert_success(client.get(f"{BASE_URL}/api/products", params={**params, "limit": 100}))
        assert data["products"]
        assert all(predicate(p) for p in data["products"])

    def test_search_and_sort(self, client):
        searched = assert_success(client.get(f"{BASE_URL}/api/products", params={"q": "walnut", "limit": 100}))["products"]
        assert searched and all("walnut" in (p["name"] + " " + p["description"] + " " + " ".join(p["tags"])).lower() for p in searched)
        sorted_products = assert_success(client.get(f"{BASE_URL}/api/products", params={"sort": "price", "limit": 100}))["products"]
        assert [p["price"] for p in sorted_products] == sorted(p["price"] for p in sorted_products)

    def test_welcome_coupon_and_minimum(self, client):
        valid = assert_success(client.post(f"{BASE_URL}/api/coupons/validate", json={"code": "welcome10", "subtotal": 1500}))
        assert valid["coupon"]["code"] == "WELCOME10"
        assert valid["discount"] == 150
        too_low = client.post(f"{BASE_URL}/api/coupons/validate", json={"code": "WELCOME10", "subtotal": 500})
        assert too_low.status_code == 400, too_low.text
        assert "Minimum subtotal" in too_low.json()["message"]
        missing = client.post(f"{BASE_URL}/api/coupons/validate", json={"code": "DOES_NOT_EXIST", "subtotal": 5000})
        assert missing.status_code == 404, missing.text
        assert missing.json()["success"] is False


class TestAuthorizationAndAdminFeatures:
    """Admin/non-admin guards, settings regression, coupon CRUD, and analytics schema."""

    def test_non_admin_is_forbidden(self, client, user):
        user_headers = headers(user)
        for method, path, payload in [
            ("put", "/api/settings/hero_headline", {"value": "TEST forbidden"}),
            ("get", "/api/coupons", None),
            ("get", "/api/admin/analytics", None),
        ]:
            response = getattr(client, method)(f"{BASE_URL}{path}", headers=user_headers, json=payload)
            assert response.status_code == 403, f"{path}: {response.text}"
            assert response.json()["success"] is False

    def test_admin_settings_update_persists_then_restores(self, client, admin):
        admin_headers = headers(admin)
        before = assert_success(client.get(f"{BASE_URL}/api/settings"))["settings"]["hero_headline"]
        test_value = f"TEST Handcrafted Headline {uuid.uuid4().hex[:6]}"
        try:
            updated = assert_success(client.put(f"{BASE_URL}/api/settings/hero_headline", headers=admin_headers, json={"value": test_value}))["setting"]
            assert updated["key"] == "hero_headline" and updated["value"] == test_value
            assert assert_success(client.get(f"{BASE_URL}/api/settings"))["settings"]["hero_headline"] == test_value
        finally:
            assert_success(client.put(f"{BASE_URL}/api/settings/hero_headline", headers=admin_headers, json={"value": before}))

    def test_seeded_coupons_listed(self, client, admin):
        coupons = assert_success(client.get(f"{BASE_URL}/api/coupons", headers=headers(admin)))["coupons"]
        codes = {c["code"] for c in coupons}
        assert {"WELCOME10", "WOOD500"}.issubset(codes)

    def test_coupon_crud_and_invalid_states(self, client, admin):
        admin_headers = headers(admin)
        suffix = uuid.uuid4().hex[:7].upper()
        expired_code, inactive_code = f"EXP{suffix}", f"OFF{suffix}"
        created_ids = []
        try:
            expired = assert_success(client.post(f"{BASE_URL}/api/coupons", headers=admin_headers, json={
                "code": expired_code, "description": "TEST expired", "type": "percent", "value": 20,
                "minSubtotal": 0, "active": True, "expiresAt": "2020-01-01T00:00:00.000Z",
            }), 201)["coupon"]
            created_ids.append(expired["_id"])
            inactive = assert_success(client.post(f"{BASE_URL}/api/coupons", headers=admin_headers, json={
                "code": inactive_code, "description": "TEST inactive", "type": "flat", "value": 100,
                "minSubtotal": 0, "active": False,
            }), 201)["coupon"]
            created_ids.append(inactive["_id"])
            for code, expected in [(expired_code, "expired"), (inactive_code, "not active")]:
                response = client.post(f"{BASE_URL}/api/coupons/validate", json={"code": code, "subtotal": 5000})
                assert response.status_code == 400, response.text
                assert expected in response.json()["message"].lower()
            updated = assert_success(client.put(f"{BASE_URL}/api/coupons/{inactive['_id']}", headers=admin_headers, json={"active": True, "value": 125}))["coupon"]
            assert updated["active"] is True and updated["value"] == 125
            assert assert_success(client.post(f"{BASE_URL}/api/coupons/validate", json={"code": inactive_code, "subtotal": 5000}))["discount"] == 125
        finally:
            for coupon_id in created_ids:
                response = client.delete(f"{BASE_URL}/api/coupons/{coupon_id}", headers=admin_headers)
                assert response.status_code in (200, 404), response.text

    def test_admin_analytics_shape(self, client, admin):
        data = assert_success(client.get(f"{BASE_URL}/api/admin/analytics", headers=headers(admin)))
        assert set(data["stats"]) == {"revenue", "ordersCount", "productsCount", "customersCount"}
        assert data["stats"]["productsCount"] == 12
        assert all(isinstance(data["stats"][k], (int, float)) for k in data["stats"])
        assert isinstance(data["salesSeries"], list) and len(data["salesSeries"]) == 30
        assert all(set(point) == {"date", "revenue", "orders"} for point in data["salesSeries"])
        for key in ("recentOrders", "topProducts", "lowStock"):
            assert isinstance(data[key], list)


class TestAddressBook:
    """Authenticated address create/read/update/delete persistence and default behavior."""

    def test_address_crud(self, client, user):
        user_headers = headers(user)
        initial = assert_success(client.get(f"{BASE_URL}/api/addresses", headers=user_headers))["addresses"]
        assert initial == []
        created = assert_success(client.post(f"{BASE_URL}/api/addresses", headers=user_headers, json={
            "label": "TEST Home", "name": "TEST Recipient", "phone": "9999999999",
            "line1": "TEST 1 Wood Lane", "city": "Jodhpur", "state": "Rajasthan", "pincode": "342001", "country": "India",
        }), 201)["addresses"]
        assert len(created) == 1
        address = created[0]
        address_id = address["_id"]
        assert address["isDefault"] is True
        listed = assert_success(client.get(f"{BASE_URL}/api/addresses", headers=user_headers))["addresses"]
        assert len(listed) == 1 and listed[0]["_id"] == address_id
        updated = assert_success(client.put(f"{BASE_URL}/api/addresses/{address_id}", headers=user_headers, json={"city": "Jaipur", "label": "TEST Office"}))["addresses"]
        assert updated[0]["city"] == "Jaipur" and updated[0]["label"] == "TEST Office"
        deleted = assert_success(client.delete(f"{BASE_URL}/api/addresses/{address_id}", headers=user_headers))["addresses"]
        assert deleted == []
        assert assert_success(client.get(f"{BASE_URL}/api/addresses", headers=user_headers))["addresses"] == []


class TestCouponOrderAndRegression:
    """Coupon checkout/payment plus auth, cart, wishlist, review gate, and FCM regressions."""

    def test_coupon_order_payment_and_usage_increment(self, client, user, admin, catalog):
        user_headers, admin_headers = headers(user), headers(admin)
        product = next(p for p in catalog if p["slug"] == "walnut-sunburst-wall-art")
        coupons = assert_success(client.get(f"{BASE_URL}/api/coupons", headers=admin_headers))["coupons"]
        welcome = next(c for c in coupons if c["code"] == "WELCOME10")
        before_used, before_stock = welcome["usedCount"], product["stock"]
        order = None
        try:
            assert_success(client.delete(f"{BASE_URL}/api/cart", headers=user_headers))
            cart = assert_success(client.post(f"{BASE_URL}/api/cart/add", headers=user_headers, json={"productId": product["_id"], "quantity": 1}))["cart"]
            assert len(cart["items"]) == 1 and cart["items"][0]["product"]["_id"] == product["_id"]
            created = assert_success(client.post(f"{BASE_URL}/api/orders", headers=user_headers, json={
                "shippingAddress": {"name": user["user"]["name"], "phone": "9999999999", "line1": "TEST 2 Carver Road", "city": "Jodhpur", "state": "Rajasthan", "pincode": "342001", "country": "India"},
                "couponCode": "WELCOME10",
            }), 201)
            order = created["order"]
            assert order["couponCode"] == "WELCOME10"
            assert order["discount"] == 500
            assert order["total"] == order["subtotal"] - order["discount"] + order["shipping"] + order["tax"]
            assert created["razorpay"]["mock"] is True
            paid = assert_success(client.post(f"{BASE_URL}/api/orders/verify", headers=user_headers, json={
                "orderId": order["_id"], "razorpay_order_id": created["razorpay"]["orderId"],
                "razorpay_payment_id": "TEST_mock_payment", "razorpay_signature": "TEST_mock_signature",
            }))["order"]
            assert paid["paymentStatus"] == "paid" and paid["status"] == "paid"
            refreshed = assert_success(client.get(f"{BASE_URL}/api/coupons", headers=admin_headers))["coupons"]
            used_after_first = next(c for c in refreshed if c["code"] == "WELCOME10")["usedCount"]
            assert used_after_first == before_used + 1
            stock_after_first = assert_success(client.get(f"{BASE_URL}/api/products/{product['_id']}"))["product"]["stock"]
            assert stock_after_first == before_stock - 1

            # Payment verification retries must be idempotent and not repeat inventory/coupon side effects.
            repeated_data = assert_success(client.post(f"{BASE_URL}/api/orders/verify", headers=user_headers, json={
                "orderId": order["_id"], "razorpay_order_id": created["razorpay"]["orderId"],
                "razorpay_payment_id": "TEST_mock_payment", "razorpay_signature": "TEST_mock_signature",
            }))
            assert repeated_data.get("alreadyVerified") is True
            repeated = repeated_data["order"]
            assert repeated["paymentStatus"] == "paid"
            after_retry_coupons = assert_success(client.get(f"{BASE_URL}/api/coupons", headers=admin_headers))["coupons"]
            assert next(c for c in after_retry_coupons if c["code"] == "WELCOME10")["usedCount"] == used_after_first
            assert assert_success(client.get(f"{BASE_URL}/api/products/{product['_id']}"))["product"]["stock"] == stock_after_first
            assert assert_success(client.get(f"{BASE_URL}/api/cart", headers=user_headers))["cart"]["items"] == []
            fetched = assert_success(client.get(f"{BASE_URL}/api/orders/{order['_id']}", headers=user_headers))["order"]
            assert fetched["discount"] == 500 and fetched["couponCode"] == "WELCOME10"
        finally:
            # Restore seeded coupon usage and product stock altered by the required mock checkout.
            assert_success(client.put(f"{BASE_URL}/api/coupons/{welcome['_id']}", headers=admin_headers, json={"usedCount": before_used}))
            assert_success(client.put(f"{BASE_URL}/api/products/{product['_id']}", headers=admin_headers, json={"stock": before_stock}))
            client.delete(f"{BASE_URL}/api/cart", headers=user_headers)

    def test_auth_refresh_profile_fcm_wishlist_and_review_gate(self, client, user, catalog):
        user_headers = headers(user)
        refreshed = assert_success(client.post(f"{BASE_URL}/api/auth/refresh", json={"refreshToken": user["refreshToken"]}))
        assert isinstance(refreshed["accessToken"], str) and isinstance(refreshed["refreshToken"], str)
        assert refreshed["refreshToken"] != user["refreshToken"]
        user["accessToken"], user["refreshToken"] = refreshed["accessToken"], refreshed["refreshToken"]
        user_headers = headers(user)
        profile = assert_success(client.put(f"{BASE_URL}/api/auth/profile", headers=user_headers, json={"name": user["user"]["name"], "phone": "9876543210"}))["user"]
        assert profile["phone"] == "9876543210"
        assert_success(client.post(f"{BASE_URL}/api/auth/fcm-token", headers=user_headers, json={"token": f"TEST_fcm_{uuid.uuid4().hex}"}))
        product = catalog[0]
        ids_before = assert_success(client.get(f"{BASE_URL}/api/wishlist/ids", headers=user_headers))["ids"]
        was_present = product["_id"] in ids_before
        toggled = assert_success(client.post(f"{BASE_URL}/api/wishlist/toggle", headers=user_headers, json={"productId": product["_id"]}))
        assert toggled["added"] is (not was_present)
        restored = assert_success(client.post(f"{BASE_URL}/api/wishlist/toggle", headers=user_headers, json={"productId": product["_id"]}))
        assert restored["added"] is was_present
        review_list = assert_success(client.get(f"{BASE_URL}/api/products/{product['_id']}/reviews", headers=user_headers))
        assert isinstance(review_list["reviews"], list)

    def test_cart_rejects_invalid_and_excess_quantities_on_add_and_update(self, client, user, catalog):
        user_headers = headers(user)
        product = catalog[0]
        try:
            assert_success(client.delete(f"{BASE_URL}/api/cart", headers=user_headers))

            for quantity in (0, -1, 1.5, product["stock"] + 1):
                response = client.post(
                    f"{BASE_URL}/api/cart/add",
                    headers=user_headers,
                    json={"productId": product["_id"], "quantity": quantity},
                )
                assert response.status_code == 400, f"add quantity={quantity}: {response.text}"
                body = response.json()
                assert body["success"] is False and isinstance(body["message"], str)
                if quantity == product["stock"] + 1:
                    assert body["message"] == f"Only {product['stock']} available in stock"

            added = assert_success(client.post(
                f"{BASE_URL}/api/cart/add",
                headers=user_headers,
                json={"productId": product["_id"], "quantity": 1},
            ))["cart"]
            assert len(added["items"]) == 1 and added["items"][0]["quantity"] == 1

            for quantity in (-1, 1.5, product["stock"] + 1):
                response = client.put(
                    f"{BASE_URL}/api/cart/item",
                    headers=user_headers,
                    json={"productId": product["_id"], "quantity": quantity},
                )
                assert response.status_code == 400, f"update quantity={quantity}: {response.text}"
                body = response.json()
                assert body["success"] is False and isinstance(body["message"], str)
                if quantity == product["stock"] + 1:
                    assert body["message"] == f"Only {product['stock']} available in stock"

            updated = assert_success(client.put(
                f"{BASE_URL}/api/cart/item",
                headers=user_headers,
                json={"productId": product["_id"], "quantity": 2},
            ))["cart"]
            assert updated["items"][0]["quantity"] == 2
        finally:
            client.delete(f"{BASE_URL}/api/cart", headers=user_headers)

    def test_unauthenticated_protected_regression(self, client):
        for path in ("/api/cart", "/api/addresses", "/api/wishlist", "/api/orders"):
            response = client.get(f"{BASE_URL}{path}")
            assert response.status_code == 401, f"{path}: {response.text}"
            assert response.json()["success"] is False



class TestDependencyRecoverySmoke:
    """Focused 502 recovery, authentication, catalog, and auth-playbook regression checks."""

    def test_api_root_is_healthy(self, client):
        data = assert_success(client.get(f"{BASE_URL}/api/"))
        assert data == {"success": True, "message": "WOOD CARVERS API", "ok": True}

    def test_admin_login_succeeds_with_admin_role(self, client, admin_credentials):
        data = assert_success(client.post(f"{BASE_URL}/api/auth/login", json=admin_credentials))
        assert data["user"]["email"] == admin_credentials["email"]
        assert data["user"]["role"] == "admin"
        assert isinstance(data["accessToken"], str) and data["accessToken"]
        assert isinstance(data["refreshToken"], str) and data["refreshToken"]

    def test_customer_register_then_login(self, client):
        suffix = uuid.uuid4().hex[:10]
        payload = {
            "name": f"TEST Recovery Customer {suffix}",
            "email": f"test_recovery_{suffix}@example.test",
            "password": "RecoveryPass123!",
        }
        registered = assert_success(client.post(f"{BASE_URL}/api/auth/register", json=payload), 201)
        assert registered["user"]["email"] == payload["email"]
        assert registered["user"]["role"] == "user"
        logged_in = assert_success(client.post(
            f"{BASE_URL}/api/auth/login",
            json={"email": payload["email"], "password": payload["password"]},
        ))
        assert logged_in["user"]["email"] == payload["email"]
        assert logged_in["user"]["role"] == "user"

    def test_products_still_return_exactly_twelve_wooden_products(self, client):
        products = assert_success(client.get(f"{BASE_URL}/api/products", params={"limit": 100}))["products"]
        assert len(products) == 12
        assert all(product["brand"] == "WOOD CARVERS" for product in products)
        assert len({product["slug"] for product in products}) == 12

    def test_settings_still_return_hero_configuration(self, client):
        settings = assert_success(client.get(f"{BASE_URL}/api/settings"))["settings"]
        assert isinstance(settings["hero_image"], str) and settings["hero_image"].startswith("https://")
        assert settings["hero_headline"] == "Handcrafted Elegance for Every Home"
        assert isinstance(settings["hero_subheading"], str) and settings["hero_subheading"]

    def test_admin_password_uses_bcrypt_2b_hash(self, admin_credentials):
        import json
        import subprocess

        result = subprocess.run(
            ["node", "tests/auth_playbook_probe.mjs", "hash", admin_credentials["email"]],
            cwd="/app/backend",
            check=True,
            capture_output=True,
            text=True,
            timeout=60,
        )
        probe_line = next(line for line in result.stdout.splitlines() if line.startswith("PROBE_RESULT="))
        probe = json.loads(probe_line.removeprefix("PROBE_RESULT="))
        assert probe["found"] is True
        assert probe["hash"].startswith("$2b$")

    def test_login_sets_httponly_auth_cookies(self, client, admin_credentials):
        response = client.post(f"{BASE_URL}/api/auth/login", json=admin_credentials)
        assert_success(response)
        cookie_headers = response.raw.headers.getlist("Set-Cookie")
        assert cookie_headers, "Login did not set any authentication cookies"
        assert all("httponly" in header.lower() for header in cookie_headers)
        assert any("access" in header.lower() for header in cookie_headers)
        assert any("refresh" in header.lower() for header in cookie_headers)

    def test_cors_uses_explicit_origin_with_credentials(self, client):
        allowed = client.options(
            f"{BASE_URL}/api/auth/login",
            headers={
                "Origin": BASE_URL,
                "Access-Control-Request-Method": "POST",
                "Access-Control-Request-Headers": "content-type",
            },
        )
        assert allowed.status_code in (200, 204), allowed.text
        assert allowed.headers.get("Access-Control-Allow-Origin") == BASE_URL
        assert allowed.headers.get("Access-Control-Allow-Credentials") == "true"
        rejected = client.options(
            f"{BASE_URL}/api/auth/login",
            headers={"Origin": "https://untrusted.example", "Access-Control-Request-Method": "POST"},
        )
        assert "Access-Control-Allow-Origin" not in rejected.headers

    def test_login_is_locked_after_five_failed_attempts(self, client):
        suffix = uuid.uuid4().hex[:10]
        payload = {
            "name": f"TEST Lockout User {suffix}",
            "email": f"test_lockout_{suffix}@example.test",
            "password": "CorrectPass123!",
        }
        assert_success(client.post(f"{BASE_URL}/api/auth/register", json=payload), 201)
        for _ in range(5):
            failed = client.post(
                f"{BASE_URL}/api/auth/login",
                json={"email": payload["email"], "password": "WrongPass123!"},
            )
            assert failed.status_code == 401, failed.text
        locked = client.post(
            f"{BASE_URL}/api/auth/login",
            json={"email": payload["email"], "password": payload["password"]},
        )
        assert locked.status_code == 429, "Correct password was accepted immediately after five failures; no lockout is enforced"
        assert "lock" in locked.json()["message"].lower()

    def test_seed_admin_updates_existing_admin_credentials(self):
        import json
        import subprocess

        result = subprocess.run(
            ["node", "tests/auth_playbook_probe.mjs", "seed-update"],
            cwd="/app/backend",
            check=True,
            capture_output=True,
            text=True,
            timeout=90,
        )
        probe_line = next(line for line in result.stdout.splitlines() if line.startswith("PROBE_RESULT="))
        probe = json.loads(probe_line.removeprefix("PROBE_RESULT="))
        assert probe["found"] is True
        assert probe["passwordUpdated"] is True
        assert probe["role"] == "admin"
        assert probe["name"] == probe["expectedName"]
