# RPG-Test

Proyek 2D RPG top-down yang dibangun dengan **Godot Engine 4.7.1** menggunakan **GDScript**, sebagai bagian dari portofolio untuk melamar magang di bidang game development.

---

## Tentang Proyek

RPG-Test dibuat sebagai portofolio untuk magang game developer. Selain itu, proyek ini juga jadi pengalaman pertama saya menyentuh game engine di luar Unity. Ternyata Godot terasa jauh lebih ringan dan simpel untuk dipakai, tapi tetap tidak kalah bagus hasilnya dibanding Unity.

Programming sendiri merupakan salah satu passion saya sebagai mahasiswa Sistem Informasi, membangun sesuatu yang bisa langsung dimainkan dan dilihat hasilnya terasa berbeda dari mengerjakan tugas kuliah pada umumnya. Proyek ini juga jadi karya kedua saya setelah sebelumnya pernah membuat game jam project di Unity.

## Kenapa RPG?

RPG adalah salah satu genre yang paling saya sukai secara personal. Ada kepuasan tersendiri dalam memperkuat karakter, menghadapi monster, dan menikmati jalan cerita yang dibangun sedikit demi sedikit.

Saya juga menyukai Visual Novel, tapi menurut saya VN lebih cocok jadi media penyampaian cerita, bukan fokus inti dari gameplay-nya meskipun storytelling-nya bisa sangat kuat. RPG memberi ruang untuk keduanya: progression sistem yang solid *dan* ruang bercerita, jadi genre ini terasa paling pas untuk dieksplorasi sebagai proyek portofolio.

## Fitur & Mekanik

- **Pergerakan & kombat** : top-down real-time dengan animasi arah (atas/bawah/kiri/kanan)
- **Sistem EXP & Leveling** : mengalahkan musuh memberi EXP, kebutuhan EXP naik seiring level (`level × 100`)
- **Status yang tumbuh tiap naik level** : Max HP, ATK, dan DEF meningkat, HP otomatis pulih penuh setiap level up
- **Damage berbasis stat** : damage yang diberikan mengikuti ATK player, damage yang diterima diredam oleh DEF player (bukan angka fixed lagi)
- **HUD real-time** : menampilkan Level, EXP bar, HP, ATK, DEF, dan jumlah musuh yang berhasil dikalahkan
- **Regenerasi HP** : otomatis setelah beberapa saat tidak terkena serangan
- **Perpindahan scene** : antar area (world ↔ cliff side) yang me-reset posisi musuh, sehingga bisa terus farming EXP
- **Ambient audio system** : suara burung, angin, dan langkah kaki yang dinamis untuk memperkuat atmosfer dunia

## Cara Main

| Tombol     | Aksi                             |
|------------|----------------------------------|
| Arrow Keys | Bergerak (atas/bawah/kiri/kanan) |
| Enter      | Menyerang                        |

Jelajahi dunia, dekati musuh (slime) dan serang mereka untuk mendapatkan EXP. Kumpulkan EXP untuk naik level — status karakter (HP, ATK, DEF) akan otomatis bertambah kuat dan HP akan pulih penuh setiap kali naik level.

Jika semua musuh di satu area sudah dikalahkan, pindah ke scene lain (misalnya area cliff side di kanan atas), lalu kembali lagi ke scene utama — musuh akan muncul kembali sehingga proses leveling bisa dilanjutkan.

## Tantangan yang Dihadapi

Membangun mekanik ini bukan tanpa hambatan. Beberapa tantangan terbesar yang saya alami:

- **Membuat node lewat kode, bukan lewat scene editor (`.tscn`)** : menjadi tantangan baru, karena hasil akhirnya tidak bisa langsung dilihat secara visual seperti biasanya di editor Godot. Perlu adaptasi cara berpikir dari "drag & drop node" menjadi "bayangkan struktur node di kepala, lalu tulis lewat script".
- **Bug pada sistem perpindahan scene (`change_scene_to_file`)** : sempat terjebak cukup lama karena scene tidak mau berpindah sesuai yang diharapkan.
- **Migrasi seluruh data pemain ke variabel global** : dilakukan demi menerapkan sistem EXP dan level dengan benar, karena node Player ternyata dihancurkan dan dibuat ulang setiap kali scene berganti, sehingga data seperti level, EXP, dan status harus disimpan di tempat yang persisten (autoload), bukan di script Player itu sendiri.

## Cara Menyelesaikan Tantangan

Pendekatan yang saya pakai kebanyakan trial-and-error: mencoba memahami kenapa kode yang secara logika seharusnya berjalan malah menghasilkan bug, lalu bereksperimen menambahkan potongan kode lain untuk memperbaikinya meski kadang perbaikan itu memunculkan bug baru yang harus ditelusuri lagi.

Untuk penggunaan AI, saya memanfaatkannya secara spesifik: membantu implementasi dasar logika sistem (seperti struktur EXP/leveling dan sinkronisasi data lewat autoload), serta memberi saran sistem tambahan apa saja yang bisa memperkuat nilai portofolio proyek ini.

## Hasil Akhir

Sampai saat ini, game sudah bisa dimainkan secara utuh: pemain bisa bergerak, menyerang musuh, mendapatkan EXP, naik level dengan status yang bertambah kuat, serta berpindah antar scene untuk terus melanjutkan proses leveling.

## Rencana Pengembangan

Beberapa hal yang direncanakan untuk ditambahkan ke depannya:

- Boss / musuh dengan mekanik yang lebih menantang
- Scene / area tambahan
- Kemungkinan elemen storytelling ringan, mengingat ketertarikan pada narasi dari genre Visual Novel

## Tech Stack

- **Engine:** Godot Engine 4.7.1
- **Bahasa:** GDScript
- **Arsitektur:** Scene-based (`world.tscn`, `cliff_side.tscn`) dengan autoload `Global` untuk data pemain, audio, dan status yang persisten lintas scene
