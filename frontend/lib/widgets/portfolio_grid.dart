import 'package:flutter/material.dart';
import 'package:hex_the_add_hub/constants/theme.dart';
import 'package:hex_the_add_hub/models/portfolio_item.dart';

class PortfolioGrid extends StatelessWidget {
  final List<PortfolioItem> items;
  final Function(PortfolioItem) onItemTap;

  const PortfolioGrid({
    Key? key,
    required this.items,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildPortfolioCard(context, item);
      },
    );
  }

  Widget _buildPortfolioCard(BuildContext context, PortfolioItem item) {
    return GestureDetector(
      onTap: () => onItemTap(item),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project image
              Expanded(
                child: item.imageUrls.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          image: DecorationImage(
                            image: NetworkImage(item.imageUrls.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.white54,
                          ),
                        ),
                      ),
              ),
              
              // Project info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: darkSecondaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildTechnologiesList(context, item.technologies),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnologiesList(BuildContext context, List<String> technologies) {
    if (technologies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show first 3 technologies, or fewer if there are less than 3
    final displayTechnologies = technologies.take(3).toList();
    final remaining = technologies.length - displayTechnologies.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...displayTechnologies.map((tech) => Chip(
              label: Text(
                tech,
                style: const TextStyle(fontSize: 10),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: primaryColor.withOpacity(0.2),
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            )),
        if (remaining > 0)
          Chip(
            label: Text(
              '+$remaining',
              style: const TextStyle(fontSize: 10),
            ),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Colors.grey.withOpacity(0.2),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
      ],
    );
  }
}
