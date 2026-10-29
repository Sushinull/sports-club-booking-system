import random
from datetime import datetime, timedelta

# รายชื่อและนามสกุลสำหรับสุ่ม
first_names = ["Somchai", "Somsak", "Kittisak", "Nattapong", "Prasert", "Ananda", "Chaiwat", "Pattama", "Siriporn", "Kanokwan", 
               "Supaporn", "Waraporn", "Jiraporn", "Siriwan", "Apinya", "Nutthida", "Kamonwan", "Thanawat", "Thanakorn", "Peerawat"]
last_names = ["Rattanakul", "Srisawat", "Wongsuwan", "Phakdeetham", "Chaiyasing", "Kaewmanee", "Suksawat", "Thongchai", "Boonmee", "Prasertsom",
              "Techawong", "Kittiwan", "Ruangrit", "Charoenphon", "Panyasak", "Arayakul", "Supapratheep", "Srinagarindra", "Wongsa", "Meethong"]

positions = ["Manager", "Receptionist", "Mechanic", "Trainer", "Cleaner"]
facility_types = ["Badminton", "Tennis", "Swimming Pool", "Basketball", "Fitness"]
methods = ["Credit Card", "PromptPay", "Cash", "Bank Transfer"]

with open("data.sql", "w", encoding="utf-8") as f:
    f.write("USE [sports_club-db];\nGO\n\n")

    # 1. Staff (10 คน)
    f.write("-- Insert Staff (10 records)\n")
    for i in range(1, 11):
        sid = f"ST{i:03d}"
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        phone = f"08{random.randint(10000000, 99999999)}"
        email = f"staff{i}@sportsclub.com"
        pos = random.choice(positions)
        f.write(f"INSERT INTO staff (staff_id, first_name, last_name, phone, email, position, status) VALUES ('{sid}', N'{fn}', N'{ln}', '{phone}', '{email}', N'{pos}', 'Active');\n")
    f.write("GO\n\n")

    # 2. Facilities (5 แห่ง)
    f.write("-- Insert Facilities (5 records)\n")
    facs = [
        ("FC001", "Central Badminton Club", "Badminton", "Building A", "08:00:00", "22:00:00"),
        ("FC002", "Grand Tennis Center", "Tennis", "Outdoor Zone", "06:00:00", "21:00:00"),
        ("FC003", "Olympic Swimming Pool", "Swimming Pool", "Building B", "06:00:00", "20:00:00"),
        ("FC004", "Pro Basketball Arena", "Basketball", "Building C", "09:00:00", "22:00:00"),
        ("FC005", "Modern Fitness Gym", "Fitness", "Building A", "06:00:00", "23:00:00")
    ]
    for fid, fn, ft, loc, op, cl in facs:
        f.write(f"INSERT INTO facilities (facility_id, facility_name, facility_type, location, opening_time, closing_time, status) VALUES ('{fid}', N'{fn}', N'{ft}', N'{loc}', '{op}', '{cl}', 'Active');\n")
    f.write("GO\n\n")

    # 3. Members (500 คน ตามเกณฑ์มินิมัม)
    f.write("-- Insert Members (500 records)\n")
    for i in range(1, 501):
        mid = f"M{i:04d}"
        fn = random.choice(first_names)
        ln = random.choice(last_names)
        phone = f"08{random.randint(10000000, 99999999)}"
        email = f"member{i}@gmail.com"
        mtype = random.choice(["Standard", "VIP", "Premium"])
        sdate = "2025-01-01"
        edate = "2026-12-31"
        f.write(f"INSERT INTO members (member_id, first_name, last_name, phone, email, membership_type, membership_start, membership_end, status) VALUES ('{mid}', N'{fn}', N'{ln}', '{phone}', '{email}', N'{mtype}', '{sdate}', '{edate}', 'Active');\n")
    f.write("GO\n\n")

    # 4. Courts (15 สนาม)
    f.write("-- Insert Courts (15 records)\n")
    court_idx = 1
    for fid, fn, ft, loc, op, cl in facs:
        for c in range(1, 4):
            cid = f"C{court_idx:03d}"
            cname = f"{ft} Court {c}"
            cap = 4 if ft in ["Badminton", "Tennis"] else 10
            rate = 150.00 if ft == "Badminton" else (300.00 if ft == "Tennis" else 200.00)
            f.write(f"INSERT INTO courts (court_id, facility_id, court_name, court_type, capacity, hourly_rate, status) VALUES ('{cid}', '{fid}', N'{cname}', N'{ft}', {cap}, {rate}, 'Available');\n")
            court_idx += 1
    f.write("GO\n\n")

    # 5. Equipment (10 รายการ)
    f.write("-- Insert Equipment (10 records)\n")
    eqs = [
        ("EQ001", "Badminton Racket", "Racket", 50, 50.00),
        ("EQ002", "Yonex Shuttlecock (Pack)", "Accessory", 100, 30.00),
        ("EQ003", "Tennis Racket", "Racket", 30, 80.00),
        ("EQ004", "Wilson Tennis Ball (Can)", "Accessory", 50, 40.00),
        ("EQ005", "Swimming Goggles", "Accessory", 40, 30.00),
        ("EQ006", "Kickboard", "Training", 30, 20.00),
        ("EQ007", "Basketball", "Ball", 20, 50.00),
        ("EQ008", "Weightlifting Belt", "Fitness", 15, 60.00),
        ("EQ009", "Resistance Band", "Fitness", 30, 25.00),
        ("EQ010", "Yoga Mat", "Fitness", 40, 30.00)
    ]
    for eid, en, et, qty, rate in eqs:
        f.write(f"INSERT INTO equipment (equipment_id, equipment_name, equipment_type, total_quantity, rental_rate, status) VALUES ('{eid}', N'{en}', N'{et}', {qty}, {rate}, 'Available');\n")
    f.write("GO\n\n")

    # 6. Court Bookings (100 รายการ) & Payments (100 รายการ)
    f.write("-- Insert Bookings & Payments (100 records)\n")
    start_date = datetime(2026, 1, 1)
    for i in range(1, 101):
        bid = f"BK{i:04d}"
        mid = f"M{random.randint(1, 500):04d}"
        cid = f"C{random.randint(1, 15):03d}"
        bdate = (start_date + timedelta(days=random.randint(0, 180))).strftime("%Y-%m-%d")
        shour = random.randint(9, 19)
        stime = f"{shour:02d}:00:00"
        etime = f"{(shour+2):02d}:00:00"
        rate = 200.00
        total = rate * 2
        f.write(f"INSERT INTO court_bookings (booking_id, member_id, court_id, booking_date, start_time, end_time, total_amount, hourly_rate_snapshot, status, created_at) VALUES ('{bid}', '{mid}', '{cid}', '{bdate}', '{stime}', '{etime}', {total}, {rate}, 'Confirmed', GETDATE());\n")
        
        pid = f"P{i:04d}"
        pmethod = random.choice(methods)
        f.write(f"INSERT INTO payments (payment_id, booking_id, amount, payment_date, payment_method, status) VALUES ('{pid}', '{bid}', {total}, GETDATE(), N'{pmethod}', 'Completed');\n")
    f.write("GO\n\n")

    # 7. Equipment Rentals (30 รายการ) & Payments
    f.write("-- Insert Equipment Rentals (30 records)\n")
    for i in range(1, 31):
        rid = f"R{i:04d}"
        mid = f"M{random.randint(1, 500):04d}"
        eid = f"EQ{random.randint(1, 10):03d}"
        rdate = (start_date + timedelta(days=random.randint(0, 180))).strftime("%Y-%m-%d")
        qty = random.randint(1, 3)
        rate = 50.00
        total = rate * qty
        f.write(f"INSERT INTO equipment_rentals (rental_id, member_id, equipment_id, rental_date, due_date, quantity, rental_rate_snapshot, total_amount, status) VALUES ('{rid}', '{mid}', '{eid}', '{rdate}', '{rdate}', {qty}, {rate}, {total}, 'Active');\n")
        
        pid = f"P{i+100:04d}"
        pmethod = random.choice(methods)
        f.write(f"INSERT INTO payments (payment_id, rental_id, amount, payment_date, payment_method, status) VALUES ('{pid}', '{rid}', {total}, GETDATE(), N'{pmethod}', 'Completed');\n")
    f.write("GO\n\n")

    # 8. Maintenance (10 รายการ)
    f.write("-- Insert Maintenance (10 records)\n")
    for i in range(1, 11):
        mtid = f"MT{i:03d}"
        sid = f"ST{random.randint(1, 10):03d}"
        fid = f"FC{random.randint(1, 5):03d}"
        mdate = (start_date + timedelta(days=random.randint(0, 180))).strftime("%Y-%m-%d")
        cost = random.randint(1, 10) * 500.00
        f.write(f"INSERT INTO maintenance (maintenance_id, staff_id, facility_id, maintenance_date, description, cost, status) VALUES ('{mtid}', '{sid}', '{fid}', '{mdate}', N'Routine maintenance check', {cost}, 'Completed');\n")
    f.write("GO\n")

print("สร้างไฟล์ data.sql สำเร็จ!")