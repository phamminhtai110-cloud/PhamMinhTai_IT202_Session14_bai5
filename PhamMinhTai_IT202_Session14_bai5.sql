USE RikkeiClinicDB;

DROP PROCEDURE IF EXISTS FindEmptyBed;

DELIMITER //

CREATE PROCEDURE FindEmptyBed(
    IN p_department_id INT,
    OUT p_bed_id INT
)
BEGIN

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_department_id
      AND patient_id IS NULL
    LIMIT 1;

END //

DELIMITER ;

DROP PROCEDURE IF EXISTS EmergencyAdmission;

DELIMITER //

CREATE PROCEDURE EmergencyAdmission(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_time DATETIME,
    IN p_department_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_bed_id INT;
    DECLARE v_count INT;
    DECLARE v_new_appointment_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Loi: He thong gap su co';
    END;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO v_count
    FROM Beds
    WHERE patient_id = p_patient_id;

    IF v_count > 0 THEN

        ROLLBACK;

        SET p_message = 'Tu choi: Benh nhan dang luu tru';

    ELSE

        SELECT COUNT(*)
        INTO v_count
        FROM Departments
        WHERE dept_id = p_department_id;

        IF v_count = 0 THEN

            ROLLBACK;

            SET p_message = 'Tu choi: Khoa khong ton tai';

        ELSE

            CALL FindEmptyBed(p_department_id, v_bed_id);

            IF v_bed_id IS NULL THEN

                ROLLBACK;

                SET p_message = 'Tu choi: Khoa hien da het giuong';

            ELSE

                SELECT IFNULL(MAX(appointment_id), 100)
                INTO v_new_appointment_id
                FROM Appointments;

                SET v_new_appointment_id = v_new_appointment_id + 1;

                INSERT INTO Appointments(
                    appointment_id,
                    patient_id,
                    doctor_id,
                    appointment_date,
                    status
                )
                VALUES(
                    v_new_appointment_id,
                    p_patient_id,
                    p_doctor_id,
                    p_appointment_time,
                    'Pending'
                );

                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = v_bed_id;

                COMMIT;

                SET p_message = 'Nhap vien thanh cong';

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;

SET @message = '';

CALL EmergencyAdmission(
    3,
    101,
    '2026-06-15 08:00:00',
    2,
    @message
);

SELECT @message AS Result;

SET @message = '';

CALL EmergencyAdmission(
    3,
    101,
    '2026-06-15 09:00:00',
    3,
    @message
);

SELECT @message AS Result;

SET @message = '';

CALL EmergencyAdmission(
    1,
    101,
    '2026-06-15 10:00:00',
    2,
    @message
);

SELECT @message AS Result;

SET @message = '';

CALL EmergencyAdmission(
    3,
    101,
    '2026-06-15 11:00:00',
    999,
    @message
);

SELECT @message AS Result;