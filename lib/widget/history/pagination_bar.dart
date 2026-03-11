import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final Function(int) onPageChanged; // ฟังก์ชันที่จะถูกเรียกตอนกดเปลี่ยนหน้า

  const PaginationBar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🟢 ปุ่มย้อนกลับ
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: currentPage > 1 ? Colors.black : Colors.grey,
            onPressed: currentPage > 1 && !isLoading 
                ? () => onPageChanged(currentPage - 1) 
                : null,
          ),
          
          // 🟢 ตัวเลขหน้า
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalPages, (index) {
                  int pageNum = index + 1;
                  bool isSelected = pageNum == currentPage;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: !isLoading && !isSelected 
                          ? () => onPageChanged(pageNum) 
                          : null,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: isSelected ? const Color(0xFF7E8CFD) : Colors.transparent,
                        child: Text(
                          '$pageNum',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // 🟢 ปุ่มถัดไป
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: currentPage < totalPages ? Colors.black : Colors.grey,
            onPressed: currentPage < totalPages && !isLoading 
                ? () => onPageChanged(currentPage + 1) 
                : null,
          ),
        ],
      ),
    );
  }
}