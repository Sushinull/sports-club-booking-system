// กำหนด URL สำหรับ Backend API
const API_BASE_URL = 'http://localhost:5000/api';

// -------------------------------------------------------------
// คลังคำแปล TH / EN
// -------------------------------------------------------------
const translations = {
    th: {
        splash_title: "ยินดีต้อนรับสู่ระบบบริการการกีฬา",
        splash_subtitle: "Sports Club & Facility Booking System",
        btn_enter: "เข้าสู่เว็บไซต์",
        news_title: "News:",
        news_text: "ขอเชิญชวนนิสิตและบุคลากรใช้บริการจองสนามและยืมอุปกรณ์กีฬาออนไลน์ผ่านระบบใหม่ได้แล้ววันนี้! | ป้องกันการจองซ้ำด้วยระบบ Real-time Conflict Checking",
        brand_title: "ศูนย์บริการการกีฬาและนันทนาการ",
        brand_subtitle: "SPORTS & RECREATION SERVICES CENTER",
        nav_home: "หน้าแรก",
        nav_booking: "จองสนามและยืมอุปกรณ์",
        nav_members: "จัดการสมาชิก",
        nav_analytics: "ระบบสารสนเทศ/สรุปข้อมูล",
        nav_contact: "ติดต่อเรา",
        hero_title: "พื้นที่ และสนามกีฬา",
        hero_subtitle: "เปิดให้บริการสนามแบดมินตัน ฟุตซอล บาสเกตบอล และยืมอุปกรณ์กีฬาสำหรับนิสิตและบุคลากร",
        service_title: "บริการหลักของระบบ",
        menu_court: "จองสนามและยืมอุปกรณ์",
        menu_reports: "รายงานสรุปการใช้งาน",
        menu_revenue: "สรุปรายได้สถานที่",
        menu_member: "จัดการรายชื่อสมาชิก",
        menu_guide: "คู่มือการใช้งาน",
        booking_heading: "ทำรายการจองสนามและยืมอุปกรณ์",
        lbl_booking_id: "รหัสการจอง (Booking ID)",
        lbl_member_id: "รหัสสมาชิก (Member ID)",
        lbl_court_id: "เลือกสนาม (Court ID)",
        lbl_date: "วันที่จอง",
        lbl_start_time: "เวลาเริ่มต้น",
        lbl_end_time: "เวลาสิ้นสุด",
        lbl_payment_id: "รหัสชำระเงินค่าสนาม (Payment ID)",
        lbl_payment_method: "ช่องทางชำระเงิน",
        lbl_opt_equip: "บริการยืมอุปกรณ์เพิ่มเติม (Optional)",
        lbl_equip_id: "รหัสอุปกรณ์ (Equipment ID)",
        lbl_quantity: "จำนวนที่ต้องการยืม",
        lbl_rental_id: "รหัสรายการยืม (Rental ID)",
        lbl_equip_payment_id: "รหัสชำระค่าอุปกรณ์ (Equip Payment ID)",
        btn_submit: "ยืนยันการจองสนามและประมวลผลธุรกรรม",
        analytics_heading: "สรุปข้อมูลรายงานการเข้าใช้บริการ (Reporting View)",
        kpi_total_bookings: "ยอดการจองสนามรวม",
        kpi_total_hours: "ชั่วโมงการใช้งานรวม",
        kpi_total_revenue: "รายได้รวมทั้งหมด",
        btn_refresh: "โหลดข้อมูลรายงานล่าสุด",
        th_facility: "ชื่อสถานที่",
        th_type: "ประเภท",
        th_year: "ปี",
        th_week: "สัปดาห์ที่",
        th_bookings: "จำนวนครั้งที่จอง",
        th_hours: "ชั่วโมงรวม",
        th_revenue: "รายได้รวม (บาท)"
    },
    en: {
        splash_title: "Welcome to Sports Club System",
        splash_subtitle: "Sports Club & Facility Booking System",
        btn_enter: "Enter Website",
        news_title: "News:",
        news_text: "Welcome students & staff to our online facility booking system! | Built-in Real-time Conflict Checking system.",
        brand_title: "Sports & Recreation Services Center",
        brand_subtitle: "SPORTS & RECREATION SERVICES CENTER",
        nav_home: "Home",
        nav_booking: "Book Court & Equipment",
        nav_members: "Member Management",
        nav_analytics: "Data Analytics",
        nav_contact: "Contact Us",
        hero_title: "Facilities & Sports Courts",
        hero_subtitle: "Badminton, Football, Basketball courts and sports equipment available for students and staff.",
        service_title: "Main Services",
        menu_court: "Book Court & Equipment",
        menu_reports: "Usage Reports",
        menu_revenue: "Revenue Summary",
        menu_member: "Manage Members",
        menu_guide: "Usage Guide",
        booking_heading: "Facility Booking & Equipment Rental",
        lbl_booking_id: "Booking ID",
        lbl_member_id: "Member ID",
        lbl_court_id: "Select Court",
        lbl_date: "Booking Date",
        lbl_start_time: "Start Time",
        lbl_end_time: "End Time",
        lbl_payment_id: "Court Payment ID",
        lbl_payment_method: "Payment Method",
        lbl_opt_equip: "Equipment Rental Options (Optional)",
        lbl_equip_id: "Equipment ID",
        lbl_quantity: "Quantity",
        lbl_rental_id: "Rental ID",
        lbl_equip_payment_id: "Equipment Payment ID",
        btn_submit: "Confirm Booking & Process Transaction",
        analytics_heading: "Facility Utilization Analytics (Reporting View)",
        kpi_total_bookings: "Total Court Bookings",
        kpi_total_hours: "Total Hours Booked",
        kpi_total_revenue: "Total Revenue Generated",
        btn_refresh: "Reload Analytics Data",
        th_facility: "Facility Name",
        th_type: "Type",
        th_year: "Year",
        th_week: "Week No.",
        th_bookings: "Bookings Count",
        th_hours: "Total Hours",
        th_revenue: "Total Revenue (THB)"
    }
};

let currentLang = 'th';

// ฟังก์ชันสลับภาษา TH / EN
function changeLanguage(lang) {
    currentLang = lang;
    document.querySelectorAll('[data-key]').forEach(elem => {
        const key = elem.getAttribute('data-key');
        if (translations[lang] && translations[lang][key]) {
            elem.innerText = translations[lang][key];
        }
    });

    const btnTh = document.getElementById('btn-th');
    const btnEn = document.getElementById('btn-en');
    if (btnTh) btnTh.classList.toggle('active', lang === 'th');
    if (btnEn) btnEn.classList.toggle('active', lang === 'en');
}

// 1. กดปุ่มเข้าสู่เว็บไซต์จาก Splash Screen
function enterWebsite() {
    const splash = document.getElementById('splash-screen');
    if (splash) {
        splash.style.opacity = '0';
        setTimeout(() => {
            splash.style.display = 'none';
        }, 500);
    }
}

// 2. สลับหน้าเว็บแบบ SPA
function switchPage(pageName) {
    document.querySelectorAll('.page-section').forEach(sec => sec.classList.remove('active'));
    document.querySelectorAll('.nav-links a').forEach(a => a.classList.remove('active'));

    const targetPage = document.getElementById(`page-${pageName}`);
    if (targetPage) targetPage.classList.add('active');

    const activeNav = document.getElementById(`nav-${pageName}`);
    if (activeNav) activeNav.classList.add('active');

    if (pageName === 'analytics') {
        fetchReports();
    } else if (pageName === 'members') {
        fetchMembers();
    }
}

// 3. ส่งฟอร์มจองสนามและยืมอุปกรณ์
const bookingForm = document.getElementById('bookingForm');
if (bookingForm) {
    bookingForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const payload = {
            booking_id: document.getElementById('booking_id')?.value,
            member_id: document.getElementById('member_id')?.value,
            court_id: document.getElementById('court_id')?.value,
            booking_date: document.getElementById('booking_date')?.value,
            start_time: document.getElementById('start_time')?.value,
            end_time: document.getElementById('end_time')?.value,
            payment_id_court: document.getElementById('payment_id_court')?.value,
            payment_method: document.getElementById('payment_method')?.value,
            equipment_id: document.getElementById('equipment_id')?.value || null,
            equip_quantity: parseInt(document.getElementById('equip_quantity')?.value) || 0,
            rental_id: document.getElementById('rental_id')?.value || null,
            payment_id_equip: document.getElementById('payment_id_equip')?.value || null
        };

        try {
            const response = await fetch(`${API_BASE_URL}/bookings`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            const resData = await response.json();

            if (response.ok) {
                alert(currentLang === 'th' ? 'ทำรายการสำเร็จ: ' + resData.message : 'Success: ' + resData.message);
            } else {
                alert(currentLang === 'th' ? 'เกิดข้อผิดพลาด: ' + (resData.error || resData.message) : 'Error: ' + (resData.error || resData.message));
            }
        } catch (err) {
            alert(currentLang === 'th' ? 'ไม่สามารถเชื่อมต่อกับ Backend Server ได้' : 'Cannot connect to backend server');
        }
    });
}

// 4. ดึงข้อมูลรายงานสรุปจาก Reporting View
async function fetchReports() {
    try {
        const response = await fetch(`${API_BASE_URL}/reports/utilization`);
        const rows = await response.json();
        const tbody = document.getElementById('reportTbody');
        if (!tbody) return;

        tbody.innerHTML = '';

        let totalBookings = 0;
        let totalHours = 0;
        let totalRevenue = 0;

        rows.forEach(r => {
            totalBookings += r.total_court_bookings || 0;
            totalHours += r.total_hours_booked || 0;
            totalRevenue += r.total_court_revenue || 0;

            tbody.innerHTML += `
                <tr>
                    <td><strong>${r.facility_name}</strong></td>
                    <td>${r.facility_type}</td>
                    <td>${r.booking_year}</td>
                    <td>${r.booking_week}</td>
                    <td>${r.total_court_bookings}</td>
                    <td>${r.total_hours_booked} ${currentLang === 'th' ? 'ชม.' : 'hrs'}</td>
                    <td>฿${(r.total_court_revenue || 0).toLocaleString()}</td>
                </tr>
            `;
        });

        const elBookings = document.getElementById('kpi-bookings');
        const elHours = document.getElementById('kpi-hours');
        const elRevenue = document.getElementById('kpi-revenue');

        if (elBookings) elBookings.innerText = totalBookings.toLocaleString();
        if (elHours) elHours.innerText = totalHours.toLocaleString();
        if (elRevenue) elRevenue.innerText = '฿' + totalRevenue.toLocaleString();

    } catch (err) {
        const tbody = document.getElementById('reportTbody');
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="7" class="text-center" style="color:red;">${currentLang === 'th' ? 'ไม่สามารถโหลดข้อมูลจาก Server ได้' : 'Failed to load data from server'}</td></tr>`;
        }
    }
}

// 5. ระบบค้นหา Real-time ใน Analytics Dashboard
const searchInput = document.getElementById('globalSearchInput');
if (searchInput) {
    searchInput.addEventListener('input', function (e) {
        const keyword = e.target.value.trim().toLowerCase();
        const rows = document.querySelectorAll('#reportTbody tr');

        if (keyword.length > 0 && !document.getElementById('page-analytics')?.classList.contains('active')) {
            switchPage('analytics');
        }

        rows.forEach(row => {
            const rowText = row.innerText.toLowerCase();
            if (rowText.includes(keyword)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
}

// 6. ดึงข้อมูลสมาชิกและค้นหารายชื่อจาก Backend API
async function fetchMembers() {
    const searchInput = document.getElementById('memberSearchInput');
    const searchQuery = searchInput ? searchInput.value.trim() : '';
    const tbody = document.getElementById('memberTableBody');

    if (!tbody) return;

    tbody.innerHTML = '<tr><td colspan="5" style="text-align: center;">กำลังโหลดข้อมูลสมาชิก...</td></tr>';

    const url = searchQuery 
        ? `${API_BASE_URL}/members?search=${encodeURIComponent(searchQuery)}`
        : `${API_BASE_URL}/members`;

    try {
        const response = await fetch(url);
        const data = await response.json();

        tbody.innerHTML = '';

        if (!Array.isArray(data) || data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" style="text-align: center;">ไม่พบข้อมูลสมาชิก</td></tr>';
            return;
        }

        data.forEach(member => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td><strong>${member.member_id || '-'}</strong></td>
                <td>${member.first_name || ''} ${member.last_name || ''}</td>
                <td>${member.phone || '-'}</td>
                <td>${member.email || '-'}</td>
                <td>${member.membership_type || 'Standard'}</td>
            `;
            tbody.appendChild(row);
        });
    } catch (error) {
        console.error('Error fetching members:', error);
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: red;">เกิดข้อผิดพลาดในการโหลดข้อมูลสมาชิก</td></tr>';
    }
}

// 7. เริ่มต้นทำงานเมื่อโหลด DOM เรียบร้อยแล้ว
document.addEventListener('DOMContentLoaded', () => {
    // โหลดข้อมูลสมาชิกครั้งแรกเมื่อเปิดเว็บ
    fetchMembers();
});