# PhamMinhTai_IT202_Session14_bai5

# [Sáng tạo] Tự động hóa nhập viện khẩn cấp

# 1. Phân tích yêu cầu

## Input
- `p_patient_id` : Mã bệnh nhân
- `p_doctor_id` : Mã bác sĩ
- `p_appointment_time` : Thời gian khám
- `p_department_id` : Mã khoa

## Output
- `p_message` : Thông báo trạng thái

---

# 2. Thiết kế giao tiếp giữa Procedure

## Procedure phụ
### `FindEmptyBed`

Nhiệm vụ:
- Tìm giường trống trong khoa.

### Kiểu tham số

| Tham số | Loại |
|---|---|
| p_department_id | IN |
| p_bed_id | OUT |

Procedure phụ sử dụng:
- `OUT`
để trả mã giường trống về cho Procedure Master.

---

# 3. Luồng xử lý

```text
START TRANSACTION
    |
    +--> Kiểm tra bệnh nhân đang nội trú?
            |
            +--> Có
            |       |
            |       +--> ROLLBACK
            |       +--> Báo lỗi
            |
            +--> Không
                    |
                    +--> Kiểm tra khoa tồn tại?
                            |
                            +--> Không
                            |       |
                            |       +--> ROLLBACK
                            |       +--> Báo lỗi
                            |
                            +--> Có
                                    |
                                    +--> CALL FindEmptyBed()
                                            |
                                            +--> Không có giường
                                            |       |
                                            |       +--> ROLLBACK
                                            |       +--> Báo lỗi
                                            |
                                            +--> Có giường
                                                    |
                                                    +--> Tạo lịch khám
                                                    +--> Gán giường
                                                    +--> COMMIT
                                                    +--> Báo thành công
