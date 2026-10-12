import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lumo/core/constants/asset_paths.dart';

enum _PetMood {
  idle,
  petted,
  happy,
  sleeping,
}

/// An interactive pet that can be dragged around the screen.
/// Shows idle animation by default, switches to tap reaction on tap,
/// and animates smoothly when dragged.
class DraggablePet extends StatefulWidget {
  /// Size of the pet widget.
  final double petSize;

  /// Initial position offset (from top-left of parent).
  final Offset initialPosition;

  /// Constraints for pet movement (parent size).
  final Size parentSize;

  const DraggablePet({
    super.key,
    this.petSize = 180,
    required this.initialPosition,
    required this.parentSize,
  });

  @override
  State<DraggablePet> createState() => _DraggablePetState();
}

class _DraggablePetState extends State<DraggablePet>
    with TickerProviderStateMixin {
  late Offset _position;
  bool _isReacting = false;
  final bool _facingRight = true;
  _PetMood _petMood = _PetMood.idle;

  // For idle floating animation
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _onPetTapped() {
    if (_isReacting) return;
    setState(() {
      _petMood = _PetMood.petted;
      _isReacting = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _petMood = _PetMood.idle;
          _isReacting = false;
        });
      }
    });
  }

  String _petAssetForMood() {
    switch (_petMood) {
      case _PetMood.petted:
      case _PetMood.happy:
        return AssetPaths.lumoHappy;
      case _PetMood.sleeping:
        return AssetPaths.lumoSleep;
      case _PetMood.idle:
        return _isReacting ? AssetPaths.lumoTapReaction : AssetPaths.lumoIdle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        // Subtle floating effect when idle
        final floatOffset = sin(_floatController.value * pi * 2) * 4;

        return Positioned(
          left: _position.dx,
          top: _position.dy + floatOffset,
          child: GestureDetector(
            onTap: _onPetTapped,
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  _facingRight ? 1.0 : -1.0,
                  1.0,
                  1.0,
                ),
                child: SizedBox(
                  width: widget.petSize,
                  height: widget.petSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow under pet
                      Positioned(
                        bottom: 8,
                        child: Container(
                          width: widget.petSize * 0.5,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // The pet Lottie animation
                      Lottie.asset(
                        _petAssetForMood(),
                        key: ValueKey(
                            'pet-$_petMood-${_isReacting ? 'reaction' : 'idle'}'),
                        repeat: !_isReacting,
                        fit: BoxFit.contain,
                        width: widget.petSize,
                        height: widget.petSize,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              '🦊',
                              style: TextStyle(fontSize: widget.petSize * 0.48),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
