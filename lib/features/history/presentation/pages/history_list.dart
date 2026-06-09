// import 'package:calculator/core/styles/app_colors.dart';
// import 'package:calculator/core/styles/app_dimens.dart';
// import 'package:calculator/features/calculator/domain/usecases/get_calculation_history.dart';
// import 'package:calculator/features/calculator/domain/usecases/update_calculation_history.dart';
// import 'package:calculator/features/calculator/presentation/providers/calculator_history_controller.dart';
// import 'package:calculator/features/history/domain/entities/calculation_history.dart';
// import 'package:calculator/gen/assets.gen.dart';
// import 'package:calculator/core/widgets/dialogs/input_dialog.dart';
// import 'package:calculator/gen/strings.g.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
//
// final historyListProvider = FutureProvider.autoDispose<List<CalculationHistory>>((ref) async {
//   final useCase = ref.watch(getCalculationHistoryUseCaseProvider);
//   return await useCase.execute();
// });
//
// class HistoryList extends ConsumerWidget {
//   const HistoryList({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final historyAsync = ref.watch(historyListProvider);
//
//     return historyAsync.when(
//       data: (list) {
//         if (list.isEmpty) {
//           return Center(
//             child: Text(t.history.no_history_yet, style: const TextStyle(color: Colors.black54)),
//           );
//         }
//         return Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: Assets.images.bgBackgroundClassic.provider(),
//               fit: BoxFit.cover,
//               opacity: 0.2, // Độ mờ vừa phải để hiện vân kim loại
//             ),
//             color: const Color(0xFFE0E0E0), // Màu nền xám kim loại
//           ),
//           child: ListView.separated(
//             padding: EdgeInsets.zero,
//             itemCount: list.length,
//             separatorBuilder: (context, index) => Container(height: 1, color: Colors.black.withValues(alpha: 0.1)),
//             itemBuilder: (context, index) {
//               final item = list[index];
//               return _HistoryListItem(item: item);
//             },
//           ),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandOrange)),
//       error: (err, stack) => Center(child: Text('Error: $err')),
//     );
//   }
// }
//
// class _HistoryListItem extends ConsumerWidget {
//   const _HistoryListItem({required this.item});
//
//   final CalculationHistory item;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final dateStr = DateFormat('MMM dd, HH:mm').format(item.createdTime);
//
//     return InkWell(
//       onTap: () {},
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(AppDimens.gap16, 0, AppDimens.gap16, 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Row 1: Date and Icons (Sát đỉnh)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4.0),
//                   child: Text(
//                     dateStr,
//                     style: TextStyle(
//                       color: Colors.black.withValues(alpha: 0.6),
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       height: 1.0,
//                     ),
//                   ),
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (item.note.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(right: 8.0, top: 4.0),
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(maxWidth: 150),
//                           child: TextButton(
//                             child: Text(
//                               item.note,
//                               style: TextStyle(fontSize: 14, color: Colors.blue.shade600, height: 1.0),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             onPressed: () => _showNoteDialog(context, ref, item),
//                           ),
//                         ),
//                       ),
//                     IconButton(
//                       icon: const Icon(Icons.chat_bubble_outline, size: 18),
//                       color: Colors.black54,
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       visualDensity: VisualDensity.compact,
//                       onPressed: () => _showNoteDialog(context, ref, item),
//                     ),
//                     const SizedBox(width: 12),
//                     const Padding(
//                       padding: EdgeInsets.only(top: 0),
//                       child: Icon(Icons.more_vert, size: 20, color: Colors.black54),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             // Row 2: Expression and Result (Aligned Right)
//             Align(
//               alignment: Alignment.centerRight,
//               child: RichText(
//                 textAlign: TextAlign.right,
//                 text: TextSpan(
//                   style: const TextStyle(fontSize: 20, color: Colors.black87),
//                   children: [
//                     TextSpan(
//                       text: item.expression,
//                       style: const TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.black38),
//                     ),
//                     TextSpan(
//                       text: ' = ',
//                       style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(
//                       text: item.result,
//                       style: TextStyle(
//                         color: Colors.blue.shade800,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                         decorationColor: Colors.blue.shade300,
//                         decorationThickness: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showNoteDialog(BuildContext context, WidgetRef ref, CalculationHistory item) async {
//     final newNote = await InputDialog.show(
//       context: context,
//       title: t.common.edit,
//       initialValue: item.note,
//       hintText: t.common.add,
//     );
//
//     if (newNote != null) {
//       await ref.read(updateCalculationHistoryUseCaseProvider).call(item.copyWith(note: newNote));
//       // Refresh list
//       ref.invalidate(calculatorHistoryControllerProvider);
//     }
//   }
// }
