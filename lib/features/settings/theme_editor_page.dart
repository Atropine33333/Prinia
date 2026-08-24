import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/presets.dart';
import '../../core/theme/theme_controller.dart';

const _colorLabels = [
  'bg 页面背景',
  'surface 卡片',
  'text 主文字',
  'textMuted 次要文字',
  'primary 主色',
  'primaryHover 主色按压',
  'border 边框',
  'borderStrong 强边框',
  'hoverBg 悬停背景',
  'activeBg 选中背景',
  'highlight 高亮',
  'error 错误',
];

/// 自定义配色板编辑器：12 个语义色逐个调整，保存后与预设并列。
class ThemeEditorPage extends ConsumerStatefulWidget {
  const ThemeEditorPage({super.key});

  @override
  ConsumerState<ThemeEditorPage> createState() => _ThemeEditorPageState();
}

class _ThemeEditorPageState extends ConsumerState<ThemeEditorPage> {
  late List<Color> _colors;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 以当前主题为底稿
    final current = presetThemes.first.colors;
    _colors = current.toHexList().map((h) => Color(
          int.parse(h.replaceFirst('#', ''), radix: 16) | 0xFF000000,
        )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('自定义配色板')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            maxLength: 12,
            style: TextStyle(color: colors.text, fontSize: 16),
            decoration: const InputDecoration(
              hintText: '配色板名称（如：我的暗紫）',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _colorLabels.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: GestureDetector(
                onTap: () => _editColor(i),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _colors[i],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                ),
              ),
              title: Text(_colorLabels[i],
                  style: TextStyle(fontSize: 14, color: colors.text)),
              trailing: Text(
                '#${_colors[i].toARGB32().toRadixString(16).substring(2)}',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ),
          const SizedBox(height: 12),
          // 实时预览条
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: _colors[0],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colors[1],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text('预览',
                        style:
                            TextStyle(color: _colors[2], fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.favorite, color: _colors[4]),
                const SizedBox(width: 8),
                Icon(Icons.error_outline, color: _colors[11]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('保存配色板', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _editColor(int index) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _SimpleColorPicker(initial: _colors[index]),
    );
    if (picked != null) {
      setState(() => _colors[index] = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先起个名字')),
      );
      return;
    }
    final appColors = AppColors(
      bg: _colors[0],
      surface: _colors[1],
      text: _colors[2],
      textMuted: _colors[3],
      primary: _colors[4],
      primaryHover: _colors[5],
      border: _colors[6],
      borderStrong: _colors[7],
      hoverBg: _colors[8],
      activeBg: _colors[9],
      highlight: _colors[10],
      error: _colors[11],
    );
    await ref.read(themeControllerProvider.notifier).saveCustomTheme(
          name,
          appColors,
        );
    if (mounted) Navigator.of(context).pop();
  }
}

/// 简易取色器：色相环 + 饱和度/明度滑块 + hex 输入。
class _SimpleColorPicker extends StatefulWidget {
  final Color initial;
  const _SimpleColorPicker({required this.initial});

  @override
  State<_SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<_SimpleColorPicker> {
  late HSVColor _hsv;

  _SimpleColorPickerState() {
    final h = HSLColor.fromColor(widget.initial);
    _hsv = HSVColor.fromAHSV(1, h.hue, h.saturation, h.lightness);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final current = _hsv.toColor();

    return AlertDialog(
      title: const Text('选择颜色'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 色相条
          GestureDetector(
            onPanDown: (d) => _pickHue(d.localPosition.dx, context),
            onPanUpdate: (d) => _pickHue(d.localPosition.dx, context),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF0000), Color(0xFFFFFF00),
                    Color(0xFF00FF00), Color(0xFF00FFFF),
                    Color(0xFF0000FF), Color(0xFFFF00FF),
                    Color(0xFFFF0000),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('饱和度',
                  style: TextStyle(fontSize: 12, color: colors.textMuted)),
              Expanded(
                child: Slider(
                  value: _hsv.saturation,
                  activeColor: colors.primary,
                  onChanged: (v) =>
                      setState(() => _hsv = _hsv.withSaturation(v)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('明度',
                  style: TextStyle(fontSize: 12, color: colors.textMuted)),
              Expanded(
                child: Slider(
                  value: _hsv.value,
                  activeColor: colors.primary,
                  onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: current,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消', style: TextStyle(color: colors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(current),
          child: Text('确定', style: TextStyle(color: colors.primary)),
        ),
      ],
    );
  }

  void _pickHue(double dx, BuildContext context) {
    final width = context.size?.width ?? 1;
    final ratio = (dx / width).clamp(0.0, 0.9999);
    setState(() => _hsv = _hsv.withHue(ratio * 360));
  }
}
