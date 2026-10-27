# Windows 11 สำหรับเล่น Valorant แบบเบา

ไฟล์ `autounattend.xml` ไฟล์เดียว วางใน USB ตัวลง Windows แล้วลงตามปกติ ลงเสร็จได้ Windows ที่ไม่มีแอปติดเครื่อง ไม่ต้องรันอะไรเพิ่ม

## ทำอะไรบ้าง

- ลบแอปติดเครื่องทั้งหมด เหลือ Edge, Windows Security, Notepad
- ลบ Copilot, Widgets, Teams, Outlook, OneDrive, Xbox app, Game Bar, Microsoft Store
- ปิด telemetry, โฆษณาใน Start, แอปแนะนำ, ผลค้นหา Bing, Recall
- ไม่ให้ Windows เข้ารหัสดิสก์เอง, ปิด Fast Startup กับ Hibernate
- ธีมมืด, แสดงนามสกุลไฟล์, power plan High performance, timezone ไทย

## ไม่แตะ

Secure Boot, TPM, VBS, Memory Integrity, Defender, Windows Update. Vanguard ของ Valorant ตรวจสิ่งเหล่านี้ จึงเล่นได้ตามปกติ.

## ไม่เหมาะกับ

คนที่เล่นเกมจาก Microsoft Store หรือ Xbox Game Pass. ไฟล์นี้ลบ Store กับ Xbox app.

## วิธีใช้

1. ทำ USB ด้วย [Media Creation Tool](https://www.microsoft.com/software-download/windows11) หรือ [Rufus](https://rufus.ie) จาก ISO ทางการ Windows 11 24H2 ขึ้นไป
2. วาง `autounattend.xml` ไว้ที่ root ของ USB (ไดรฟ์เดียวกับโฟลเดอร์ `sources`)
3. บูตจาก USB แล้วลงตามปกติ เลือกภาษา, edition และพาร์ทิชันเอง ไฟล์นี้ไม่แบ่งดิสก์ให้
4. ตอนตั้งค่าครั้งแรกจะถามชื่อบัญชี ใช้บัญชี local ไม่ต้องล็อกอิน Microsoft

ถ้าใช้ Rufus ให้ปิดตัวเลือกปรับแต่งของ Rufus ทั้งหมด จะได้ไม่ชนกับไฟล์นี้

## หลังลง

- ลงไดรเวอร์การ์ดจอ (เฉพาะไดรเวอร์ ไม่ต้องลงแอปเสริม)
- ลง Riot Client + Valorant
- เปิด `msinfo32` ดูว่า Virtualization-based security เป็น Running

Log ของการลบแอปอยู่ที่ `C:\Windows\Setup\Scripts\Specialize.log`
