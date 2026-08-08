import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/product_card.dart';
import '../../../app/services/push_notification_service.dart';
import '../controllers/account_controller.dart';

(Color, Color) _statusColors(String status) {
  switch (status) {
    case 'paid':
      return (AppColors.primary.withOpacity(0.12), AppColors.primary);
    case 'processing':
    case 'shipped':
      return (AppColors.accent.withOpacity(0.3), AppColors.primary);
    case 'delivered':
      return (AppColors.primary, AppColors.primaryForeground);
    case 'cancelled':
    case 'failed':
      return (Colors.red.withOpacity(0.12), Colors.red);
    default:
      return (AppColors.secondary, AppColors.primary);
  }
}

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  static const _tabs = [
    ('orders', 'Orders', Icons.inventory_2_outlined),
    ('wishlist', 'Wishlist', Icons.favorite_border),
    ('addresses', 'Addresses', Icons.place_outlined),
    ('profile', 'Profile', Icons.person_outline),
    ('notifications', 'Notifications', Icons.notifications_none),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.user.value;

    if (user == null) {
      return const Scaffold(
        appBar: AppHeader(),
        body: Center(child: Text('Please sign in.', style: TextStyle(color: AppColors.mutedForeground))),
      );
    }

    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ACCOUNT', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.mutedForeground)),
                const SizedBox(height: 6),
                Text('Hi, ${user.name.split(' ').first}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 4),
                const Text('Manage your orders, saved pieces, addresses and preferences.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final (id, label, icon) in _tabs)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(icon, size: 14, color: controller.activeTab.value == id ? Colors.white : AppColors.primary),
                            const SizedBox(width: 6),
                            Text(label),
                          ]),
                          selected: controller.activeTab.value == id,
                          onSelected: (_) => controller.setTab(id),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: controller.activeTab.value == id ? Colors.white : AppColors.primary, fontSize: 12),
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    ActionChip(
                      label: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.logout, size: 14, color: AppColors.mutedForeground),
                        SizedBox(width: 6),
                        Text('Log out'),
                      ]),
                      onPressed: () => auth.logout(),
                      backgroundColor: AppColors.secondary,
                      labelStyle: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              switch (controller.activeTab.value) {
                case 'wishlist':
                  return _wishlistTab();
                case 'addresses':
                  return _addressesTab(context);
                case 'profile':
                  return _profileTab(context, user);
                case 'notifications':
                  return _notificationsTab();
                default:
                  return _ordersTab(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _ordersTab(BuildContext context) {
    return Obx(() {
      if (controller.ordersLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.orders.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.mutedForeground),
                const SizedBox(height: 16),
                const Text("You haven't placed any orders yet.", style: TextStyle(color: AppColors.mutedForeground)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => Get.toNamed(Routes.shop), child: const Text('Browse shop')),
              ],
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: controller.orders.length,
        itemBuilder: (_, i) {
          final o = controller.orders[i];
          final (bg, fg) = _statusColors(o.status);
          return GestureDetector(
            onTap: () => Get.toNamed('${Routes.orders}/${o.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${o.id.length >= 8 ? o.id.substring(o.id.length - 8) : o.id}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${o.createdAt != null ? DateFormat('d MMM y').format(o.createdAt!) : ''} · ${o.items.length} items',
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                        child: Text(o.status, style: TextStyle(fontSize: 11, color: fg)),
                      ),
                      Text(formatInr(o.total), style: const TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _wishlistTab() {
    return Obx(() {
      if (controller.wishlistLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.wishlistProducts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, size: 28, color: AppColors.mutedForeground),
                SizedBox(height: 16),
                Text('Nothing saved yet.', style: TextStyle(color: AppColors.mutedForeground)),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: GridView.builder(
          itemCount: controller.wishlistProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 14,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (_, i) => ProductCard(product: controller.wishlistProducts[i], width: double.infinity),
        ),
      );
    });
  }

  Widget _addressesTab(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (controller.addressesLoading.value) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Text('Saved delivery addresses used at checkout.',
                            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                    TextButton.icon(
                      onPressed: controller.openNewAddressForm,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (controller.addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No addresses saved yet.', style: TextStyle(color: AppColors.mutedForeground))),
                  )
                else
                  for (final a in controller.addresses)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(a.label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            if (a.isDefault) const Text('DEFAULT', style: TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.accent)),
                          ]),
                          const SizedBox(height: 6),
                          Text('${a.name} · ${a.phone}', style: const TextStyle(fontSize: 13)),
                          Text('${a.line1}${a.line2.isNotEmpty ? ', ${a.line2}' : ''}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          Text('${a.city}, ${a.state} ${a.pincode}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          const SizedBox(height: 10),
                          Row(children: [
                            GestureDetector(
                              onTap: () => controller.openEditAddressForm(a),
                              child: const Text('Edit', style: TextStyle(fontSize: 12, color: AppColors.primary, decoration: TextDecoration.underline)),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => _confirmDeleteAddress(context, a.id!),
                              child: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red, decoration: TextDecoration.underline)),
                            ),
                          ]),
                        ],
                      ),
                    ),
              ],
            ),
          );
        }),
        Obx(() => controller.isAddressFormOpen ? _addressEditorSheet(context) : const SizedBox.shrink()),
      ],
    );
  }

  void _confirmDeleteAddress(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete address?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(onPressed: () { Get.back(); controller.deleteAddress(id); }, child: const Text('Delete')),
        ],
      ),
    );
  }

  Widget _addressEditorSheet(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(18)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => Text(controller.isNewAddress.value ? 'New address' : 'Edit address',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary))),
                  const SizedBox(height: 16),
                  TextField(controller: controller.labelCtrl, decoration: const InputDecoration(hintText: 'Label (Home, Office)')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.nameCtrl, decoration: const InputDecoration(hintText: 'Full name')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.line1Ctrl, decoration: const InputDecoration(hintText: 'Street address')),
                  const SizedBox(height: 10),
                  TextField(controller: controller.line2Ctrl, decoration: const InputDecoration(hintText: 'Apartment (optional)')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: controller.cityCtrl, decoration: const InputDecoration(hintText: 'City'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: controller.stateCtrl, decoration: const InputDecoration(hintText: 'State'))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextField(controller: controller.pincodeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Pincode'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: controller.countryCtrl, decoration: const InputDecoration(hintText: 'Country'))),
                  ]),
                  Obx(() => CheckboxListTile(
                        value: controller.formIsDefault.value,
                        onChanged: (v) => controller.formIsDefault.value = v ?? false,
                        title: const Text('Default address', style: TextStyle(fontSize: 13)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      )),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: controller.closeAddressForm, child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      Obx(() => ElevatedButton(
                            onPressed: controller.savingAddress.value ? null : controller.saveAddress,
                            child: Text(controller.savingAddress.value ? 'Saving…' : 'Save'),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileTab(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: controller.profileNameCtrl, decoration: const InputDecoration(hintText: 'Full name')),
          const SizedBox(height: 10),
          TextField(
            enabled: false,
            controller: TextEditingController(text: user.email),
            decoration: const InputDecoration(hintText: 'Email', filled: true, fillColor: AppColors.secondary),
          ),
          const SizedBox(height: 10),
          TextField(controller: controller.profilePhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone')),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
                onPressed: controller.savingProfile.value ? null : controller.saveProfile,
                child: Text(controller.savingProfile.value ? 'Saving…' : 'Save changes'),
              )),
        ],
      ),
    );
  }

  Widget _notificationsTab() {
    final pushAvailable = Get.isRegistered<PushNotificationService>();
    final push = pushAvailable ? Get.find<PushNotificationService>() : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order notifications', style: TextStyle(fontSize: 17, color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text("We'll push order updates via Firebase Cloud Messaging once notifications are enabled.",
                    style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                const SizedBox(height: 14),
                if (push == null)
                  const Text('Push notifications are not configured for this build.',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))
                else
                  Obx(() => push.permissionGranted.value
                      ? const Row(children: [
                          Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Notifications enabled', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                        ])
                      : ElevatedButton(
                          onPressed: push.registering.value
                              ? null
                              : () async {
                                  final granted = await push.requestAndRegister();
                                  Get.snackbar(
                                    granted ? 'Notifications enabled' : 'Permission denied',
                                    granted ? "You'll get updates on your orders" : 'You can enable this later from device settings',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                          child: Text(push.registering.value ? 'Requesting…' : 'Enable notifications'),
                        )),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marketing preferences', style: TextStyle(fontSize: 17, color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Seasonal collection drops', style: TextStyle(fontSize: 13)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Sale & offer alerts', style: TextStyle(fontSize: 13)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
