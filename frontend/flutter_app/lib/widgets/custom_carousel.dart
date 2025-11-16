import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart' as CSController;
import 'package:video_player/video_player.dart';
import '../utils/app_constants.dart';
import '../utils/app_colors.dart';

enum CarouselMediaType { image, video }

class CarouselItem {
  final String url;
  final CarouselMediaType type;
  final String caption;
  final VoidCallback? onTap;

  CarouselItem({
    required this.url,
    required this.type,
    this.caption = '',
    this.onTap,
  });
}

class CustomCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final bool autoPlay;
  final double aspectRatio;
  final bool enlargeCenterPage;

  const CustomCarousel({
    Key? key,
    required this.items,
    this.autoPlay = true,
    this.aspectRatio = 16 / 9,
    this.enlargeCenterPage = false,
  }) : super(key: key);

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int _current = 0;
  final CSController.CarouselSliderController _controller =
      CSController.CarouselSliderController();

  // Storage for video controllers
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      if (item.type == CarouselMediaType.video) {
        final VideoPlayerController newController =
            VideoPlayerController.networkUrl(Uri.parse(item.url));

        newController.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
          newController.setLooping(true);

          if (widget.items.indexOf(item) == _current && widget.autoPlay) {
            newController.play();
          }
        });
        _videoControllers[item.url] = newController;
      }
    }
  }

  @override
  void dispose() {
    _videoControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // --- Media Builder Function ---
  Widget _buildMediaItem(CarouselItem item) {
    switch (item.type) {
      case CarouselMediaType.image:
        return Image.network(
          item.url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.dividerColor,
            child: const Icon(Icons.error, color: AppColors.textSecondary),
          ),
        );

      case CarouselMediaType.video:
        final controller = _videoControllers[item.url];
        if (controller != null && controller.value.isInitialized) {
          return AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _controller,
          items: widget.items.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: item.onTap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.kBorderRadius,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.kBorderRadius,
                      ),
                      child: _buildMediaItem(item),
                    ),
                  ),
                );
              },
            );
          }).toList(),

          options: CarouselOptions(
            height: MediaQuery.of(context).size.width / widget.aspectRatio,
            autoPlay: widget.autoPlay,
            enlargeCenterPage: widget.enlargeCenterPage,
            aspectRatio: widget.aspectRatio,
            viewportFraction: 1.0,
            autoPlayInterval: AppConstants.kCarouselAutoPlayDuration,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                if (_current < widget.items.length) {
                  final prevItem = widget.items[_current];
                  if (prevItem.type == CarouselMediaType.video) {
                    _videoControllers[prevItem.url]?.pause();
                  }
                }
                _current = index;
                final currentItem = widget.items[_current];
                if (currentItem.type == CarouselMediaType.video) {
                  _videoControllers[currentItem.url]?.play();
                }
              });
            },
          ),
        ),

        // --- Indicator Dots ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.primaryColor)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
