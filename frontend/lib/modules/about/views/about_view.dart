import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_theme.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_footer.dart';

const _paragraphs = [
  'WOOD CARVERS began in 2026 as a conversation between three friends and a third-generation carpenter in a village outside Kolkata. What began as an experiment — the way walnut felt under a plane, the way teak took an oil finish — became a small studio, then a workshop, then a family of 14 master artisans.',
  'We choose walnut, sheesham, teak, mango and acacia from managed forests. We season each cut for months before it becomes an object, and we finish every piece with natural oils and beeswax.',
  'Every WOOD CARVERS object is an heirloom in the making: we make only what feels needed, and only as many as we can care for.',
];

const _stats = [
  ('14+', 'Master artisans'),
  ('4.9★', 'Buyer rating'),
  ('12,000+', 'Homes'),
  ('2026', 'Since'),
];

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OUR STORY',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A small studio in Kolkata, working at the pace of wood.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://images.unsplash.com/photo-1611967164521-abae8fba4668?w=2000&q=85',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppColors.muted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final p in _paragraphs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        p,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.foreground,
                          height: 1.6,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      for (final (value, label) in _stats)
                        Column(
                          children: [
                            Text(
                              value,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              label.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
