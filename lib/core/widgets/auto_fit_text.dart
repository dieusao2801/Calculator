import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../features/calculator/domain/logic/calculator_engine.dart';

/// Widget hiển thị văn bản tự động co giãn, sử dụng TextField để có Cursor chuẩn Android.
/// Hỗ trợ chặn cử chỉ vuốt ngang để không bị nhầm với việc chuyển Tab trong PageView.
class AutoFitText extends StatefulWidget {
  const AutoFitText({
    super.key,
    required this.text,
    this.rawText = '',
    required this.maxFontSize,
    required this.minFontSize,
    required this.color,
    required this.fontWeight,
    this.textAlign = TextAlign.right,
    this.showCursor = false,
    this.cursorIndex = 0,
    this.onTap,
  });

  final String text;
  final String rawText;
  final double maxFontSize;
  final double minFontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final bool showCursor;
  final int cursorIndex;
  final Function(int)? onTap;

  @override
  State<AutoFitText> createState() => _AutoFitTextState();
}

class _AutoFitTextState extends State<AutoFitText> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final _engine = CalculatorEngine();
  // Dùng để locate RenderEditable thật của TextField (hit-test khớp 100% với cursor TextField).
  final GlobalKey _textFieldKey = GlobalKey();

  // Đang trong quá trình drag → tạm thời không emit onTap để tránh feedback loop
  // (controller cập nhật cursorIndex → didUpdateWidget gọi _updateSelection → set lại selection → giật).
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
    _controller.addListener(_handleSelectionChange);
    _updateSelection();
  }

  void _handleSelectionChange() {
    if (!mounted || widget.onTap == null) return;
    // Khi đang drag, chỉ di chuyển cursor cục bộ qua TextEditingController.
    // Không emit về controller để tránh trigger rebuild → _updateSelection → loop.
    if (_isDragging) return;

    // Lấy index từ chuỗi hiển thị (Formatted)
    final formattedIndex = _controller.selection.baseOffset;
    if (formattedIndex < 0) return;

    // Chuyển đổi về index của chuỗi thô (Raw) để thông báo cho Controller
    final rawIndex = _engine.formattedToRawIndex(widget.rawText, formattedIndex);

    if (rawIndex != widget.cursorIndex) {
      widget.onTap!(rawIndex);
    }
  }

  @override
  void didUpdateWidget(AutoFitText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != _controller.text) {
      _controller.removeListener(_handleSelectionChange);
      _controller.text = widget.text;
      _updateSelection();
      _controller.addListener(_handleSelectionChange);
      _ensureFocus();
    } else if (widget.cursorIndex != oldWidget.cursorIndex) {
      _updateSelection();
      _ensureFocus();
    }
  }

  /// Re-focus TextField sau khi state đổi từ ngoài (vd: restore từ history sheet/dialog)
  /// để cursor lại hiện. Bỏ qua nếu đã có focus hoặc widget không hiển thị cursor.
  void _ensureFocus() {
    if (!widget.showCursor) return;
    if (_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusNode.hasFocus) return;
      _focusNode.requestFocus();
    });
  }

  void _updateSelection() {
    // Chuyển đổi từ index thô sang index hiển thị để đặt Cursor vào đúng vị trí trên màn hình
    final formattedIndex = _engine.rawToFormattedIndex(widget.rawText, widget.cursorIndex);
    final safeIndex = formattedIndex.clamp(0, widget.text.length);

    if (_controller.selection.baseOffset != safeIndex) {
      _controller.selection = TextSelection.collapsed(offset: safeIndex);
    }
  }

  /// Traverse subtree của TextField để lấy RenderEditable thật.
  /// Trả null nếu render chưa attach (drag bắt đầu trước khi TextField mount xong).
  RenderEditable? _findRenderEditable() {
    final ctx = _textFieldKey.currentContext;
    if (ctx == null) return null;
    RenderEditable? found;
    void visit(Element element) {
      if (found != null) return;
      final ro = element.renderObject;
      if (ro is RenderEditable) {
        found = ro;
        return;
      }
      element.visitChildElements(visit);
    }
    ctx.visitChildElements(visit);
    return found;
  }

  /// Hit-test bằng RenderEditable thật của TextField để cursor khớp tuyệt đối với ngón tay.
  /// Nhận **global** position vì RenderEditable.getPositionForPoint cũng yêu cầu global.
  void _updateCursorFromGlobal(Offset globalPos) {
    if (widget.text.isEmpty || !widget.showCursor) return;
    final renderEditable = _findRenderEditable();
    if (renderEditable == null) return;

    final position = renderEditable.getPositionForPoint(globalPos);
    final safeOffset = position.offset.clamp(0, widget.text.length);

    if (_controller.selection.baseOffset != safeOffset) {
      _controller.selection = TextSelection.collapsed(offset: safeOffset);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSelectionChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double _calculateFontSize(BoxConstraints constraints) {
    var fontSize = widget.maxFontSize;
    final displayText = widget.text.isEmpty ? ' ' : widget.text;

    while (fontSize > widget.minFontSize) {
      final tp = TextPainter(
        text: TextSpan(
          text: displayText,
          style: TextStyle(fontSize: fontSize, fontWeight: widget.fontWeight),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      // Trừ đi padding mặc định của TextField để tránh bị tràn
      if (tp.width <= constraints.maxWidth - 20) break;
      fontSize -= 1;
    }
    return fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _calculateFontSize(constraints);

        return GestureDetector(
          // QUAN TRỌNG: Bắt cả 3 sự kiện horizontal drag để chiếm trọn gesture arena
          // → vừa chặn PageView swipe cướp gesture, vừa tự xử lý di chuyển cursor theo ngón tay.
          onHorizontalDragStart: (details) {
            if (widget.text.isEmpty || !widget.showCursor) return;
            _isDragging = true;
            _focusNode.requestFocus();
            _updateCursorFromGlobal(details.globalPosition);
          },
          onHorizontalDragUpdate: (details) {
            _updateCursorFromGlobal(details.globalPosition);
          },
          onHorizontalDragEnd: (_) {
            if (!_isDragging) return;
            _isDragging = false;
            // Emit lần cuối để controller biết vị trí cursor sau khi nhả tay.
            _handleSelectionChange();
          },
          onHorizontalDragCancel: () {
            if (!_isDragging) return;
            _isDragging = false;
            _handleSelectionChange();
          },
          behavior: HitTestBehavior.opaque,
          child: TextField(
            key: _textFieldKey,
            controller: _controller,
            focusNode: _focusNode,
            readOnly: true, // Chặn bàn phím hệ thống nhưng vẫn cho phép tương tác Cursor
            showCursor: widget.showCursor,
            autofocus: true,
            textAlign: widget.textAlign,
            cursorColor: widget.color,
            cursorWidth: 2.0,
            style: TextStyle(fontSize: fontSize, fontWeight: widget.fontWeight, color: widget.color, letterSpacing: 0.5),
            // Strut giữ line-height theo maxFontSize ⇒ TextField không co lại khi
            // _calculateFontSize giảm font, tránh kéo theo DisplayPanel co và
            // làm CalcGrid bị giãn ra xấu.
            strutStyle: StrutStyle(fontSize: widget.maxFontSize, forceStrutHeight: true),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        );
      },
    );
  }
}
