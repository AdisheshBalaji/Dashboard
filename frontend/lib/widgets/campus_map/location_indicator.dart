import 'package:flutter/material.dart';

enum LocationIndicatorType { pulsing, ripple }

class LocationIndicator extends StatefulWidget {
  final Offset gpsOffset;
  final LocationIndicatorType type;
  final Color? color;
  final double size;
  final double dotSize;
  final Duration duration;
  
  const LocationIndicator({
    Key? key, 
    required this.gpsOffset,
    this.type = LocationIndicatorType.pulsing,
    this.color,
    this.size = 40.0,
    this.dotSize = 8.0,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);
  
  @override
  State<LocationIndicator> createState() => _LocationIndicatorState();
}

class _LocationIndicatorState extends State<LocationIndicator> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  late Animation<double> _ripple1;
  late Animation<double> _ripple2;
  late Animation<double> _rippleOpacity1;
  late Animation<double> _rippleOpacity2;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    if (widget.type == LocationIndicatorType.pulsing) {
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      
      _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.3,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      
      _opacityAnimation = Tween<double>(
        begin: 0.3,
        end: 0.1,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      
      _controller.repeat(reverse: true);
    } else {
      _controller = AnimationController(
        duration: Duration(seconds: 3),
        vsync: this,
      );
      
      _ripple1 = Tween<double>(begin: 0.3, end: 1.5)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _ripple2 = Tween<double>(begin: 0.3, end: 1.5)
          .animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut)));
      
      _rippleOpacity1 = Tween<double>(begin: 0.8, end: 0.0)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _rippleOpacity2 = Tween<double>(begin: 0.8, end: 0.0)
          .animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut)));
      
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.blue;
    
    if (widget.type == LocationIndicatorType.pulsing) {
      return _buildPulsingIndicator(color);
    } else {
      return _buildRippleIndicator(color);
    }
  }
  
  Widget _buildPulsingIndicator(Color color) {
    return Positioned(
      left: widget.gpsOffset.dx - (widget.size / 2),
      top: widget.gpsOffset.dy - (widget.size / 2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(_opacityAnimation.value),
                    border: Border.all(
                      color: color.withOpacity(_opacityAnimation.value + 0.2), 
                      width: 1,
                    ),
                  ),
                ),
              ),
              _buildCenterDot(color),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildRippleIndicator(Color color) {
    final rippleSize = widget.size * 1.5;
    
    return Positioned(
      left: widget.gpsOffset.dx - (rippleSize / 2),
      top: widget.gpsOffset.dy - (rippleSize / 2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _ripple1.value,
                child: Container(
                  width: rippleSize,
                  height: rippleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(_rippleOpacity1.value * 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: _ripple2.value,
                child: Container(
                  width: rippleSize,
                  height: rippleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(_rippleOpacity2.value * 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              _buildCenterDot(color),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildCenterDot(Color color) {
    return Container(
      width: widget.dotSize,
      height: widget.dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );
  }
}