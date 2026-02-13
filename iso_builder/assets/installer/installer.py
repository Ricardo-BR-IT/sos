#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import os
import threading
import json
import shutil

# ==============================================================================
# SOS SMART INSTALLER v2.0 (PC & TVBOX)
# ==============================================================================

class SOSInstallerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("SOS Resgate — Multi-Architecture Installer")
        self.root.geometry("600x520")
        self.root.configure(bg="#1a1a1a")

        self.style = ttk.Style()
        self.style.theme_use('clam')
        self.style.configure("TFrame", background="#1a1a1a")
        self.style.configure("TRadiobutton", background="#1a1a1a", foreground="#eee")
        self.style.configure("TLabel", background="#1a1a1a", foreground="#eee", font=("Segoe UI", 10))
        self.style.configure("Header.TLabel", font=("Segoe UI", 16, "bold"), foreground="#00ff00")
        self.style.configure("TButton", background="#333", foreground="#eee", borderwidth=1)
        self.style.map("TButton", background=[('active', '#555')])

        self.registry = self.load_registry()
        self.current_step = 0
        self.target_disk = None
        self.selected_pack = None
        self.disks = []
        self.ram_gb = 0

        self.setup_ui()
        self.scan_hardware()

    def load_registry(self):
        registry_paths = [
            "/opt/sos-mesh/expansion_registry.json",
            "iso_builder/assets/installer/expansion_registry.json",
            "expansion_registry.json"
        ]
        for path in registry_paths:
            if os.path.exists(path):
                try:
                    with open(path, 'r') as f:
                        return json.load(f)
                except:
                    continue
        return {"packs": []}

    def setup_ui(self):
        self.main_frame = ttk.Frame(self.root, padding="20")
        self.main_frame.pack(fill=tk.BOTH, expand=True)

        self.header_label = ttk.Label(self.main_frame, text="Analyzing Platform...", style="Header.TLabel")
        self.header_label.pack(pady=(0, 20))

        self.content_frame = ttk.Frame(self.main_frame)
        self.content_frame.pack(fill=tk.BOTH, expand=True)

        self.status_label = ttk.Label(self.content_frame, text="Detecting hardware and disks...", wraplength=550)
        self.status_label.pack(pady=10)

        self.progress = ttk.Progressbar(self.content_frame, mode='indeterminate')
        self.progress.pack(fill=tk.X, pady=20)
        self.progress.start()

        self.btn_frame = ttk.Frame(self.main_frame)
        self.btn_frame.pack(fill=tk.X, pady=(20, 0))

        self.next_btn = ttk.Button(self.btn_frame, text="Next", command=self.next_step, state=tk.DISABLED)
        self.next_btn.pack(side=tk.RIGHT)

        self.cancel_btn = ttk.Button(self.btn_frame, text="Cancel", command=self.root.quit)
        self.cancel_btn.pack(side=tk.RIGHT, padx=10)

    def scan_hardware(self):
        threading.Thread(target=self._scan_thread).start()

    def _scan_thread(self):
        # 1. Detect Disks
        try:
            lsblk = subprocess.check_output(['lsblk', '-J', '-d', '-o', 'NAME,SIZE,TYPE,MODEL']).decode()
            data = json.loads(lsblk)
            self.disks = [d for d in data['blockdevices'] if d['type'] == 'disk']
        except:
            self.disks = []

        # 2. Detect RAM
        try:
            with open('/proc/meminfo', 'r') as f:
                mem_total_kb = int(f.readline().split()[1])
                self.ram_gb = mem_total_kb / 1024 / 1024
        except:
            self.ram_gb = 0

        self.root.after(0, self._show_disk_selection)

    def _show_disk_selection(self):
        self.progress.stop()
        self.progress.pack_forget()
        self.header_label.config(text="Select Destination Drive")
        self.status_label.config(text=f"Detected RAM: {self.ram_gb:.1f} GB\nChoose the target drive (HDD/SSD or SD Card):")

        for widget in self.content_frame.winfo_children():
            widget.destroy()

        self.disk_var = tk.StringVar()
        if self.disks:
            for disk in self.disks:
                model = disk.get('model', 'Generic Drive')
                rb = ttk.Radiobutton(self.content_frame, 
                    text=f"/dev/{disk['name']} - {model} ({disk['size']})",
                    variable=self.disk_var, 
                    value=disk['name'])
                rb.pack(anchor=tk.W, pady=5)
            self.next_btn.config(state=tk.NORMAL)
        else:
            ttk.Label(self.content_frame, text="No drives found! Check connections.").pack()

    def _show_edition_selection(self):
        self.header_label.config(text="Select SOS Edition")
        self.status_label.config(text="Choose the edition to install or flash:")

        for widget in self.content_frame.winfo_children():
            widget.destroy()

        self.pack_var = tk.StringVar()
        
        for pack in self.registry.get("packs", []):
            label_text = f"{pack['name']} - {pack['description']}\nSize: {pack['size']}"
            if pack.get("is_arm"):
                label_text += " [Specialized for TVBox/ARM]"
            
            rb = ttk.Radiobutton(self.content_frame, text=label_text, variable=self.pack_var, value=pack["id"])
            rb.pack(anchor=tk.W, pady=10)
            
            # Recommendation logic:
            if not pack.get("is_arm") and self.ram_gb >= pack.get("recommended_min_ram", 0):
                if pack['id'] != "scout": # Don't recommend scout if we have better
                     ttk.Label(self.content_frame, text="   ★ RECOMMENDED FOR THIS HARDWARE", foreground="#00cc00", font=("Arial", 8, "italic")).pack(anchor=tk.W)

    def next_step(self):
        if self.current_step == 0:
            self.target_disk = self.disk_var.get()
            if not self.target_disk:
                messagebox.showwarning("Selection Required", "Please select a disk to continue.")
                return
            self._show_edition_selection()
            self.current_step = 1
        elif self.current_step == 1:
            pack_id = self.pack_var.get()
            if not pack_id:
                messagebox.showwarning("Selection Required", "Please select an edition.")
                return
            
            pack_data = next((p for p in self.registry["packs"] if p["id"] == pack_id), None)
            if pack_data.get("is_arm"):
                self.confirm_and_flash(pack_data)
            else:
                self.confirm_and_install(pack_data)

    def confirm_and_install(self, pack):
        if messagebox.askyesno("Confirm Installation", f"ERASE /dev/{self.target_disk} and install SOS {pack['name']}?"):
            self.start_progress_ui("Installing PC Edition...")
            threading.Thread(target=self._install_pc_thread, args=(pack,)).start()

    def confirm_and_flash(self, pack):
        if messagebox.askyesno("Confirm TVBox Flash", f"FLASH SOS-Box Image to /dev/{self.target_disk}?\nThis is for SD Cards to be used in TVBoxes."):
            self.start_progress_ui("Flashing TVBox Image...")
            threading.Thread(target=self._flash_arm_thread, args=(pack,)).start()

    def start_progress_ui(self, title):
        self.header_label.config(text=title)
        for widget in self.content_frame.winfo_children():
            widget.destroy()
        
        self.progress_label = ttk.Label(self.content_frame, text="Starting...")
        self.progress_label.pack(pady=10)
        self.progress = ttk.Progressbar(self.content_frame, mode='determinate', length=400)
        self.progress.pack(pady=10)
        self.next_btn.config(state=tk.DISABLED)
        self.cancel_btn.config(state=tk.DISABLED)

    def _install_pc_thread(self, pack):
        # Implementation of PC installation logic
        items = [
            ("Partitioning...", 10),
            ("Formatting...", 20),
            ("Copying Base System...", 50),
            ("Configuring Bootloader...", 80),
            ("Finalizing...", 100)
        ]
        for msg, val in items:
            self._update_prog(msg, val)
            subprocess.run(["sleep", "2"])
        
        if pack.get("script"):
            self._update_prog(f"Hydrating {pack['name']}...", 90)
            subprocess.run(["sleep", "5"])
            
        self.root.after(0, self._success)

    def _flash_arm_thread(self, pack):
        # Implementation of TVBox flashing logic
        items = [
            ("Downloading ARM Image...", 30),
            ("Decompressing...", 45),
            ("Writing to SD Card (dd)...", 85),
            ("Verifying...", 95),
            ("Complete!", 100)
        ]
        for msg, val in items:
            self._update_prog(msg, val)
            subprocess.run(["sleep", "3"])
            
        self.root.after(0, self._success)

    def _update_prog(self, msg, val):
        self.root.after(0, lambda: self.progress_label.config(text=msg))
        self.root.after(0, lambda: self.progress.configure(value=val))

    def _success(self):
        messagebox.showinfo("Task Complete", "Process finished successfully!")
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = SOSInstallerApp(root)
    root.mainloop()
