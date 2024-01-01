import 'package:chatapp/models/upload_progress_model.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadBox extends ConsumerStatefulWidget {
  final UploadProgressModel uploadProgressModel;
  const UploadBox({
    super.key,
    required this.uploadProgressModel,
  });

  @override
  ConsumerState<UploadBox> createState() => _UploadBoxState();
}

class _UploadBoxState extends ConsumerState<UploadBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          color: ColorPallete.lightGreenTheme,
          borderRadius: BorderRadius.circular(15)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              bottom: 0,
              child: Text(
                "${(widget.uploadProgressModel.uploadedBytes / 1048576).toStringAsFixed(2)} / ${(widget.uploadProgressModel.totalBytes / 1048576).toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 13),
              )),
          Slider(
            onChanged: (value) {},
            value: widget.uploadProgressModel.uploadedBytes,
            max: widget.uploadProgressModel.totalBytes,
            min: 0,
          ),
        ],
      ),
    );
  }
}
