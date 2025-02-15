# UART-Verification
- Môi trường kiểm thử được thiết kế dựa trên uart_spec_final_exam.pdf.
- Generator tạo Transaction theo các giá trị ngẫu nhiên đã thiết kế.
- Driver đưa các bộ tín hiệu Transaction từ Generator đến DUT thông qua Interface. Chu kỳ gửi tín hiệu phải phù hợp với baudrate của UART là 115200.
- Các bộ tín hiệu trong Transaction được random tất cả các giá trị có thể xảy ra (5-6-7-8 data_bit_num, 0-1 parity bit, 1-2 stop bit).
- Driver sẽ làm sai parity bit một cách ngẫu nhiên để kiểm tra khả năng phát hiện lỗi sai bit parity của DUT.
- Đầu ra của DUT (rx_data và parity_error) sẽ được Monitor lấy thông qua Interface.
- Scoreboard sẽ lấy Transaction từ Generator để tạo golden output và so sánh đầu ra của DUT được Monitor lấy mẫu. Kết quả so sánh sẽ được dùng để đánh giá các chức năng của DUT.
* Kết quả kiểm thử với 1000 Transactions:

  ![image](https://github.com/user-attachments/assets/2a2e8c05-d213-49d1-b133-4a31696de0ab)
