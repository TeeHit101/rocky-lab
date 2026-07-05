# Rocky Linux 9 KVM/Libvirt Lab

Detta reporitoarium innehåller skript och konfigurationer för att sätta upp en labbmiljö med Rocky Linux 9 virtuella maskiner i KVM/libvirt med hjälp av `cloud-init`.

## Struktur

*   **`config/`**: Innehåller den gemensamma konfigurationsfilen `config.sh` för labbmiljön.
*   **`scripts/`**: Innehåller skript för att verifiera värddatorn, skapa diskar, generera cloud-init-avbildningar och starta virtuella maskiner.

---

## Förutsättningar

Innan du kör skripten, se till att följande är installerat och konfigurerat på värddatorn:

1.  **KVM/Libvirt och UEFI (OVMF):**
    Eftersom Rocky Linux 9 cloud-avbildningar kräver UEFI för att starta måste du ha UEFI-firmware installerad på värddatorn (t.ex. `edk2-ovmf` på RHEL/Rocky-baserade system eller `ovmf` på Debian/Ubuntu-baserade system).
2.  **SSH-nyckel:**
    En ed25519 SSH-nyckel måste finnas på sökvägen `~/.ssh/id_ed25519.pub` för att automatiskt kunna läggas till i de virtuella maskinerna via cloud-init.
3.  **Bas-avbildning:**
    Ladda ner Rocky Linux 9 GenericCloud-avbildningen till `/var/lib/libvirt/images/` med namnet `Rocky-9-GenericCloud.latest.x86_64.qcow2`.

---

## Konfiguration

Inställningar för RAM, CPU, diskar, nätverk samt namn på de olika virtuella maskinerna (`rocky-mgmt`, `rocky-node1`, `rocky-node2`) hittar du i [`config/config.sh`](config/config.sh).

---

## Användning

### 1. Verifiera värddatorn
Kör följande skript för att kontrollera att virtualization är aktivt, att det förvalda nätverket (`default`) är igång och att bas-avbildningen ligger på rätt plats:
```bash
./scripts/check-host.sh
```

### 2. Skapa diskar och cloud-init för en VM
För att skapa disken (som en copy-on-write-overlay mot bas-avbildningen) samt generera en ISO-avbildning för cloud-init (`seed.iso`), kör följande kommandon (kräver `sudo` för att skriva till `/var/lib/libvirt/images`):
```bash
# Ersätt <vm-namn> med t.ex. rocky-mgmt
sudo ./scripts/create-vm.sh <vm-namn>
sudo ./scripts/create-cloudinit.sh <vm-namn>
```

### 3. Installera och starta VM:en
Importera och starta den virtuella maskinen i libvirt med:
```bash
./scripts/install-vm.sh <vm-namn>
```
*Skriptet kör `virt-install` med `--boot uefi` och importerar diskarna utan grafik (`--graphics none`).*

---

## Hantera och ansluta till maskinerna

### Hitta IP-adress
Efter att en VM har startat (kan ta upp till 30-60 sekunder för UEFI-boot och cloud-init att slutföras), kan du se dess IP-adress genom att hämta DHCP-leases från libvirt-nätverket:
```bash
virsh net-dhcp-leases default
```

### Anslut med SSH
När du har hittat IP-adressen kan du logga in som användaren `devops` med din SSH-nyckel:
```bash
ssh devops@<ip-adress>
```
Användaren `devops` har fulla sudo-rättigheter utan lösenord (`NOPASSWD:ALL`).

### Ansluta till seriekonsolen
Om du behöver felsöka starten eller ansluta direkt via konsolen:
```bash
virsh console <vm-namn>
```
*(Tryck på `Ctrl + ]` för att avsluta konsolsessionen).*

### Rensa och ta bort en VM
Om du vill ta bort en virtuell maskin helt:
```bash
virsh destroy <vm-namn>
virsh undefine <vm-namn> --remove-all-storage
```
