#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox
import subprocess
import os
import threading
import json
import shutil

# ==============================================================================
# SOS SMART INSTALLER v1.0
# ==============================================================================
# "Trojan Horse" Strategy:
# 1. Detect Hardware (Disk/RAM)
# 2. Offer Edition Upgrade based on hardware
# 3. Partition & Install
# 4. Hydrate (Download & Expand)
# ==============================================================================

class SOSInstallerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("SOS Resgate Platform Installer")
        self.root.geometry("600x450")
        self.root.configure(bg="#1a1a1a")

        self.style = ttk.Style()
        self.style.theme_use('clam')
        self.style.configure("TFrame", background="#1a1a1a")
        self.style.configure("TLabel", background="#1a1a1a", foreground="#eee", font=("Segoe UI", 10))
        self.style.configure("Header.TLabel", font=("Segoe UI", 16, "bold"), foreground="#ff3333")
        self.style.configure("TButton", background="#333", foreground="#eee", borderwidth=1)
        self.style.map("TButton", background=[('active', '#555')])

        self.current_step = 0
        self.target_disk = None
        self.selected_edition = "scout"
        self.disks = []

        self.setup_ui()
        self.scan_hardware()

    def setup_ui(self):
        self.main_frame = ttk.Frame(self.root, padding="20")
        self.main_frame.pack(fill=tk.BOTH, expand=True)

        self.header_label = ttk.Label(self.main_frame, text="System Analysis...", style="Header.TLabel")
        self.header_label.pack(pady=(0, 20))

        self.content_frame = ttk.Frame(self.main_frame)
        self.content_frame.pack(fill=tk.BOTH, expand=True)

        self.status_label = ttk.Label(self.content_frame, text="Scanning hardware...", wraplength=550)
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
        except Exception as e:
            self.disks = []
            print(f"Error scanning disks: {e}")

        # 2. Detect RAM
        try:
            with open('/proc/meminfo', 'r') as f:
                mem_total_kb = int(f.readline().split()[1])
                self.ram_gb = mem_total_kb / 1024 / 1024
        except:
            self.ram_gb = 0

        # Update UI
        self.root.after(0, self._show_disk_selection)

    def _show_disk_selection(self):
        self.progress.stop()
        self.progress.pack_forget()
        self.header_label.config(text="Select Target Drive")
        self.status_label.config(text=f"System RAM: {self.ram_gb:.1f} GB\nSelect the drive to install SOS (WARNING: All data will be erased):")

        for widget in self.content_frame.winfo_children():
            widget.destroy()

        self.disk_var = tk.StringVar()
        if self.disks:
            for disk in self.disks:
                rb = ttk.Radiobutton(self.content_frame, 
                    text=f"/dev/{disk['name']} - {disk['model']} ({disk['size']})",
                    variable=self.disk_var, 
                    value=disk['name'],
                    style="TRadiobutton")
                rb.pack(anchor=tk.W, pady=5)
            self.next_btn.config(state=tk.NORMAL)
        else:
            ttk.Label(self.content_frame, text="No suitable disks found!").pack()

    def next_step(self):
        if self.current_step == 0: # Disk Selection -> Edition Selection
            self.target_disk = self.disk_var.get()
            if not self.target_disk:
                messagebox.showerror("Error", "Please select a disk.")
                return
            self._show_edition_selection()
            self.current_step = 1
        elif self.current_step == 1: # Edition Selection -> Install
            self.start_installation()

    def _show_edition_selection(self):
        self.header_label.config(text="Select SOS Edition")
        
        # Logic to recommend edition
        disk_size_gb = self._get_disk_size_gb(self.target_disk)
        
        rec_text = "Based on your hardware, we recommend:"
        if disk_size_gb > 120 and self.ram_gb >= 8:
            rec_edition = "omega"
            rec_text += " OMEGA (Survival + AI)"
        elif disk_size_gb > 30:
            rec_edition = "ranger"
            rec_text += " RANGER (Maps + Wiki)"
        else:
            rec_edition = "scout"
            rec_text += " SCOUT (Minimal)"

        for widget in self.content_frame.winfo_children():
            widget.destroy()

        ttk.Label(self.content_frame, text=rec_text, foreground="#00cc00").pack(pady=(0, 15))

        self.edition_var = tk.StringVar(value=rec_edition)

        # Omega Option
        f1 = ttk.Frame(self.content_frame, borderwidth=1, relief="solid")
        f1.pack(fill=tk.X, pady=5)
        r1 = ttk.Radiobutton(f1, text="OMEGA (~64GB) - Full Survival AI + Wikipedia", variable=self.edition_var, value="omega")
        r1.pack(anchor=tk.W, padx=10, pady=5)
        if disk_size_gb < 64: r1.config(state=tk.DISABLED)

        # Ranger Option
        f2 = ttk.Frame(self.content_frame, borderwidth=1, relief="solid")
        f2.pack(fill=tk.X, pady=5)
        r2 = ttk.Radiobutton(f2, text="RANGER (~16GB) - Offline Maps + Medical Wiki", variable=self.edition_var, value="ranger")
        r2.pack(anchor=tk.W, padx=10, pady=5)
        if disk_size_gb < 16: r2.config(state=tk.DISABLED)

        # Scout Option
        f3 = ttk.Frame(self.content_frame, borderwidth=1, relief="solid")
        f3.pack(fill=tk.X, pady=5)
        r3 = ttk.Radiobutton(f3, text="SCOUT (~2GB) - Minimal Mesh System", variable=self.edition_var, value="scout")
        r3.pack(anchor=tk.W, padx=10, pady=5)

        self.next_btn.config(text="Install")

    def _get_disk_size_gb(self, disk_name):
        # Simplified parser, assumes lsblk size string like "500G" or "1.8T"
        for d in self.disks:
            if d['name'] == disk_name:
                s = d['size']
                if 'T' in s: return float(s.replace('T', '')) * 1024
                if 'G' in s: return float(s.replace('G', ''))
                if 'M' in s: return float(s.replace('M', '')) / 1024
        return 0

    def start_installation(self):
        edition = self.edition_var.get()
        confirm = messagebox.askyesno("Confirm Install", 
            f"WARNING: All data on /dev/{self.target_disk} will be ERASED.\n\n"
            f"Installing SOS {edition.upper()} Edition.\n\nContinue?")
        
        if not confirm: return

        self.header_label.config(text="Installing...")
        for widget in self.content_frame.winfo_children():
            widget.destroy()
        
        self.status_label = ttk.Label(self.content_frame, text="Partitioning disk...")
        self.status_label.pack(pady=10)
        
        self.progress = ttk.Progressbar(self.content_frame, mode='determinate')
        self.progress.pack(fill=tk.X, pady=20)
        self.progress['value'] = 0
        
        self.next_btn.config(state=tk.DISABLED)
        self.cancel_btn.config(state=tk.DISABLED)

        threading.Thread(target=self._install_thread, args=(edition,)).start()

    def _install_thread(self, edition):
        disk = f"/dev/{self.target_disk}"
        
        try:
            # 1. Partitioning
            self._update_status("Partitioning disk...", 10)
            # Use sgdisk/parted (simulated command for safety in this script)
            # subprocess.run(f"parted -s {disk} mklabel gpt", shell=True, check=True)
            # subprocess.run(f"parted -s {disk} mkpart ESP fat32 1MiB 513MiB", shell=True, check=True)
            # subprocess.run(f"parted -s {disk} set 1 boot on", shell=True, check=True)
            # subprocess.run(f"parted -s {disk} mkpart ROOT ext4 513MiB 100%", shell=True, check=True)
            import time; time.sleep(2) # Simulating partition

            # 2. Formatting
            self._update_status("Formatting partitions...", 20)
            # subprocess.run(f"mkfs.vfat -F32 {disk}1", shell=True)
            # subprocess.run(f"mkfs.ext4 -F {disk}2", shell=True)
            time.sleep(2)

            # 3. Installing Base System (Scout)
            self._update_status("Copying base system...", 40)
            # subprocess.run(f"mount {disk}2 /mnt", shell=True)
            # subprocess.run("cp -ax / /mnt", shell=True) # Dangerous rsync logic
            time.sleep(3)

            # 4. Hydrating (Installing additional packs)
            if edition != "scout":
                self._update_status(f"Downloading {edition.upper()} pack...", 60)
                # This would run: hydrate_ranger.sh or hydrate_omega.sh
                # subprocess.run(f"/opt/sos-mesh/hydrate_{edition}.sh --target /mnt", shell=True)
                time.sleep(5)

            # 5. Bootloader
            self._update_status("Installing Bootloader (GRUB)...", 90)
            # subprocess.run(f"grub-install --root-directory=/mnt {disk}", shell=True)
            time.sleep(2)

            self._update_status("Installation Complete!", 100)
            self.root.after(0, self._install_success)

        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror("Error", str(e)))

    def _update_status(self, text, percent):
        self.root.after(0, lambda: self.status_label.config(text=text))
        self.root.after(0, lambda: self.progress.configure(value=percent))

    def _install_success(self):
        messagebox.showinfo("Success", "SOS System Installed Successfully!\n\nRemove installation media and reboot.")
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = SOSInstallerApp(root)
    root.mainloop()
