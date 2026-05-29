
🧰 USB-EX: Systems Engineering IT Multi-Tool 🧰
====================================================================================================
#### The USB-EX project is a high-performance, automated IT diagnostic, recovery, and deployment platform. It is engineered to act as an autonomous "Crash Cart" and "Super IT Tool."

&emsp;When plugged into a compromised, failing, or offline host machine, USB-EX provides immediate access to bare-metal boot environments, zero-dependency portable applications, offline driver provisioning, and an advanced PowerShell scripting engine capable of extracting deep system telemetry and snapping diagnostic applications into visual grid layouts.

&emsp;To maximize operational speed, the drive utilizes the Prefix Trick (.Shortcut_Name.lnk) to force critical tools and scripts to sort alphabetically at the very top of their respective directories, ensuring zero-friction access during high-pressure triage.

&nbsp;


⚙️ The Core Foundation ⚙️
----------------------------------------------------------------------------------------------------

#### 💾 The Ventoy Dual-Partition System

&emsp;The USB-EX hardware is fundamentally powered by the open-source Ventoy bootloader, on a SanDisk Ultra USB 3.0 (128GB / ~114GB usable):

* VTOYEFI (D:) : A hidden 32MB FAT partition where Ventoy securely stores its EFI boot files, protecting them from accidental deletion or formatting.

* Ventoy (E:) (Root) : The primary exFAT data partition, providing cross-platform file transfer capabilities (Windows, Linux, macOS) while housing the entire USB-EX file hierarchy and payload.

#### ⚡ The Execution Engine: USBEX_Loader.bat

&emsp;Because modern Windows environments block unsigned PowerShell scripts by default (Execution Policy: Restricted), USB-EX uses a specialized batch file named USBEX_Loader.bat. Placed inside the automation subfolders, this loader acts as a skeleton key. By dragging and dropping any .ps1 script onto this loader, it temporarily bypasses the Windows Execution Policy for that single session, executes the script, and safely closes, all without permanently altering the host computer's global security posture.

&nbsp;


🗄️ Directories & Capabilities 🗄️
----------------------------------------------------------------------------------------------------

#### 🗂️ E:\ (Root) - Main Control

&emsp;The 3-second deployment zone. When the drive is inserted, you have instant access to:

* .02_Launch_PortableApps.lnk: The master menu for your suite.

* Triage Shortcuts: Prefixed shortcuts (e.g., .Ultimate_Task_Manager, .Instant_Hardware_Scan) pointing directly to System Informer and HWiNFO for immediate crisis intervention.

* README.md: This master documentation file.

&nbsp;


#### 🔧 00_USB_Maintenance_Setups

&emsp;The backend infrastructure hub. Dedicated entirely to the maintenance, synchronization, and initial setup of the USB-EX drive itself.

* Contains offline installers for the portable suites (PortableApps.exe, SyMenu.exe, LiberKey.exe) to rebuild the drive if corrupted.

* Contains .Sync_USB_Backups and .Update_Ventoy_Bootloader shortcuts to maintain drive health.

&nbsp;


#### 💿 01_Bootable_ISOs

&emsp;The bare-metal payload zone powered by Ventoy. Allows you to boot directly into raw .iso and .img files without burning them to disks.

* Hardware_Diagnostics: Bare-metal troubleshooting tools like MemTest86.img and Hiren's BootCD.iso.

* Operating_Systems: Offline deployment media including Windows 10, Windows 11, Ubuntu Desktop/Server, and Arch Linux.

&nbsp;


#### 📲 02_PortableApps

&emsp;The "System32" of the USB drive. A highly optimized, aggressively pruned, zero-bloat repository of over 100 standalone applications.

* These tools leave no registry traces on the host OS.

* Contains industry standards for monitoring (HWiNFO, Process Monitor), file management (7-Zip, Everything), and forensics (Detect It Easy, Resource Hacker).

* Total footprint is kept lean (under 30GB) to preserve space for massive data recovery operations.

&nbsp;


#### 📦 03_App_Installers

&emsp;A categorized repository (Browsers, IDEs, Simulations, etc.) for heavy offline software deployments, such as AutoCAD, Python, Visual Studio, and Discord.

* Includes prefixed shortcuts at the root to forcefully rip out OEM bloatware (.Force_Uninstall_Bloatware -> GeekUninstaller) and clear system caches (.Clean_OS_Temp_Files -> BleachBit) prior to running installations.

&nbsp;


#### 📜 04_Automation_Scripts

&emsp;The operational core of the USB-EX project, strictly driven by PowerShell.

* USBEX_Core.psm1: The master module. It dynamically resolves the USB drive letter across different host PCs, provides the Export-USBEXData function for JSON standardization, and injects C# user32.dll API hooks to dynamically calculate screen resolution and snap GUI windows into geometric grids.

* Harvesters (Phase 2): 100-level scripts that silently interrogate WMI/CIM classes to extract hardware specs, network topology, security postures, and event logs, dumping them into pristine .json files.

* Dashboards (Phase 3): 200-level scripts that utilize the Core's Set-AppGrid math to launch combinations of portable apps into perfect, taskbar-aware screen layouts (Fullscreen, 50/50 Splits, or 2x2 Quarters) for manual triage.

* Remedies (Phase 4): 300-level scripts designed for silent, background remediation, such as resetting network stacks, performing zero-friction data backups, and scrubbing OS caches.

&nbsp;


#### 🌐 05_Driver_Repositories

&emsp;The offline network bridge.

* Powered by Snappy Driver Installer Origin (SDIO).

* Contains the "Network Only" offline driver packs to restore Wi-Fi and LAN connectivity to machines lacking internet access, deliberately omitting massive 25GB+ graphical driver packs to save drive space.

* Surrounded by prefixed networking shortcuts (.Test_Local_Network, .Trace_Network_Routing) to verify packet routing immediately after driver installation.

&nbsp;


#### 🛡️ 06_Data_Recovery_Security

&emsp;The Emergency Crash Cart.

* CGSecurity_Tools: Houses TestDisk for rebuilding destroyed partition tables and repairing boot sectors, alongside PhotoRec for ignoring broken file systems to read raw disk sectors and carve out lost files.

* .Malware_Detection: Offline, dual-engine threat hunting with Emsisoft Emergency Kit and Trellix Stinger.

* Harvest_Logs: The master output destination for all JSON telemetry files generated by the Harvester scripts (e.g., Hardware_for_PC_on_Date.json).

* Recovered_Data: A safe, empty landing zone reserved specifically for files rescued by PhotoRec or FastCopy.

* Remediation_Logs: A dedicated directory for capturing text and JSON execution logs output by the Phase 4 Active Remedy scripts.

&nbsp;


#### 📔 07_Documentation

&emsp;The offline knowledge base.

* Contains reference materials, technical manuals, Unicode character maps, and tools like ZoomIt (.Magnify_Screen_Details) mapped perfectly for reading documentation and presenting data.

&nbsp;


⚡ Execution Protocols & Automation Workflows ⚡
----------------------------------------------------------------------------------------------------

#### 🔎 Phase 2: The Harvester Scripts

&emsp;These scripts extract data silently and standardize it via the Core engine into the 06_Data_Recovery_Security\Harvest_Logs folder.

* 01 Hardware: Dumps CPU, RAM, Motherboard, BIOS, and SMART disk health.

* 02 Network: Dumps IP config, DNS, routing tables, and saved WLAN profiles/keys.

* 03 Users: Lists local accounts and parses Security Event Logs for logon timelines.

* 04 Software: Scrapes registries for installed applications and OS keys.

* 05 Connections: Maps live TCP/UDP endpoints to their exact local processes.

* 06 Security: Checks Defender, BitLocker, Firewall, and UAC states.

* 07 Startups: Exposes ghost processes via Registry Run keys and scheduled tasks.

* 08 Logs: Extracts 7 days of Critical/Error events and BSODs.

* 09 USBs: Scrapes USBSTOR registry keys for a forensic history of plugged-in devices.

* 10 Omnibus: Silently executes all the above into one massive Omnibus JSON record.

&nbsp;


#### 🎚️ Phase 3: The Dashboards

&emsp;These scripts launch multi-tool interfaces snapped perfectly to your monitor using the Core's dynamic C# ratio calculation (XPercent, YPercent)

* 01 Hardware & Storage Health Hub: Snaps HWiNFO, Speccy, and CrystalDiskInfo into a visual layout for live diagnostics.

* 02 Network Traffic & Routing Hub: Snaps TCPView and Angry IP Scanner to map localized subnets.

* 03 User Accounts & Access Hub: Snaps Event Viewer (Security) and a Native User Audit (CMD).

* 04 Software & Licensing Hub: Snaps WizTree and Geek Uninstaller for visual block mapping and uninstalls.

* 05 Live Connections & Sockets Hub: Snaps System Informer, Resource Monitor, and Windows Defender Firewall.

* 06 Security Posture & AV Hub: Snaps Emsisoft Emergency Kit, Firewall configurations, and Windows Security Center.

* 07 Startups & Ghost Processes Hub: Snaps Autoruns, Task Manager, and Services for deep persistence hunting.

* 08 System Event Logs Hub: Snaps Event Viewer, Reliability Monitor, and Windows Error Lookup Tool.

* 09 USB History & Transfers Hub: Snaps Disk Management and FastCopy for drive administration.

* 10 Device Anomalies & Drivers Hub: Snaps Device Manager, System Information, and Computer Management.

* 11 Network Mappings & Shares Hub: Snaps Shared Folders, System Configuration, and FreeCommander.

* 12 Deep System Configs Hub: Snaps Registry Editor, RegShot, and grepWin for forensic tracking.

&nbsp;


#### 🛠️ Phase 4: Active Remedies

&emsp;Silent, non-interactive "Fire and Forget" scripts that repair the host OS and log their actions to 06_Data_Recovery_Security\Remediation_Logs.

* 01 System Scrub: Silently clears temp files, prefetch, software distribution cache, and executes BleachBit.

* 02 Network Purifier: Silently flushes DNS, resets Winsock, releases/renews IP, and clears ARP cache.

* 03 Account Lockdown: Disables the local Guest account, forces logoff of stale RDP sessions, and locks the workstation.

* 04 Bloatware Purge: Silently rips out consumer bloatware and Windows telemetry via PowerShell Appx commands.

* 05 Kill Rogue Sockets: Terminates unauthorized ESTABLISHED network connections and gracefully kills their parent processes.

* 06 Force Shields Up: Forces a Defender signature update, enables maximum UAC, and turns all firewall profiles ON.

* 07 Nuke Unknown Startups: Disables unsigned/unverified Registry Run keys and suspends unauthorized tasks.

* 08 Log Flush & Reset: Clears stale Windows Application/Temp logs and safely resets a corrupted WMI repository.

* 09 USB History Wipe: Clears ghosted USB devices from the registry and strictly disables AutoRun across the host.

* 10 PnP Driver Reset: Restarts the Print Spooler, clears corrupted print queues, and resets the Plug-and-Play cache.

* 11 SMB Hardening: Silently forces the disabling of vulnerable SMBv1 via registry and restricts anonymous share access.

* 12 Hosts & DNS Restore: Clears proxy settings cache and completely overwrites a poisoned hosts file with the safe Microsoft template.

&nbsp;


⚠️ Operational Safety Warnings ⚠️
----------------------------------------------------------------------------------------------------
1. The Golden Rule of Data Recovery: If using PhotoRec or TestDisk in Folder 06, NEVER save the recovered files back onto the host PC's failing drive. Always route recovered files to E:\06_Data_Recovery_Security\Recovered_Data to prevent permanently overwriting invisible data.

2. Drive Ejection: The primary data partition is formatted in exFAT for cross-platform compatibility. It does not possess the journaling safety features of NTFS. You must always use the Windows "Safely Remove Hardware" function before physically unplugging the drive to prevent total partition corruption.

3. Privilege Isolation (UIPI): When running Phase 3 Dashboards, Windows User Interface Privilege Isolation will block the script from snapping windows that launch as Administrator. You must right-click USBEX_Loader.bat and select "Run as Administrator" before dragging and dropping your 200-level scripts.

4. Linux Compatibility: The PowerShell scripts, .bat loaders, and C# GUI grid-snapping functions rely on the Windows kernel and will not run on a live Linux desktop. To repair Linux machines, reboot the host and utilize the raw ISOs inside 01_Bootable_ISOs via Ventoy.
