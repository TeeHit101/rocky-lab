# Studie- och Labbplan: Linuxtekniker (Säkerhet & Automation) på Handelsbanken

Denna plan är skräddarsydd utifrån jobbannonsen för rollen **Linuxtekniker - Säkerhet & Automation** på Handelsbanken. Planen fokuserar på att använda din 3-VM labbmiljö med Rocky Linux 9 (som är fullt kompatibelt med RHEL) för att bygga de kompetenser som efterfrågas.

---

## 🎯 Nyckelområden från jobbannonsen
1.  **Linux OS (RHEL/Rocky Linux):** Djup förståelse för pakethantering, systemtjänster och konfiguration.
2.  **Ansible Automation:** Automatisera driftsättning, konfigurering och underhåll över flera noder.
3.  **Skriptning (Bash/Python):** Skriva skript för automatisering och övervakning.
4.  **Patchning och uppgraderingar:** Hantera livscykel och säkerhetsuppdateringar.
5.  **Säkerhet:** Härdning av OS, rättigheter och nätverkssäkerhet.

---

## 🛠️ Labbarkitektur
Din labbmiljö består av tre noder:
*   **`rocky-mgmt`**: Din kontrollnod (där du installerar Ansible och styr miljön).
*   **`rocky-node1`**: Målnod 1 (applikations-/webbserver).
*   **`rocky-node2`**: Målnod 2 (databas-/säkerhetsnod).

---

## 🚀 Steg-för-steg Labbövningar

### Övning 1: Sätt upp Ansible Control Node
**Mål:** Konfigurera `rocky-mgmt` för att styra `rocky-node1` och `rocky-node2` utan lösenord.
*   **Moment:**
    1.  Installera Ansible på `rocky-mgmt` via EPEL-förrådet:
        ```bash
        sudo dnf install epel-release -y
        sudo dnf install ansible-core -y
        ```
    2.  Skapa en `hosts`-fil (inventory) på `rocky-mgmt` som definierar dina servrar.
    3.  Konfigurera SSH-nycklar mellan `rocky-mgmt` (användaren `devops`) och de två noderna.
    4.  Verifiera anslutningen med Ansibles ping-modul:
        ```bash
        ansible all -m ping -i hosts
        ```

### Övning 2: Säkerhetspatchning med Ansible
**Mål:** Automatisera säkerhetsuppdateringar och patchning, vilket är en central del av rollen.
*   **Moment:**
    1.  Skriv en Ansible-playbook (`patch.yml`) som:
        *   Kör `dnf update` med fokus på enbart säkerhetsuppdateringar (`--security`).
        *   Kontrollerar om en omstart krävs (t.ex. om kerneln uppdaterats) med hjälp av `needs-restarting` (ingår i `dnf-utils`).
        *   Startar om servern på ett säkert sätt om det behövs och väntar på att den kommer online igen.
    2.  Kör din playbook mot alla noder.

### Övning 3: Säkerhetshärdning (Säkerhet)
**Mål:** Konfigurera grundläggande säkerhet enligt bästa praxis för RHEL/Rocky.
*   **Moment:**
    1.  Skriv en playbook för att:
        *   Inaktivera SSH-inloggning för `root` och tvinga användning av SSH-nycklar (inaktivera lösenordsinloggning).
        *   Konfigurera brandväggen (`firewalld`) till att endast tillåta nödvändiga portar (SSH, HTTP/HTTPS).
        *   Installera och aktivera `fail2ban` för att skydda mot brute force-attacker.
    2.  Verifiera att reglerna har applicerats på noderna.

### Övning 4: Övervakningsskript (Skriptning)
**Mål:** Skapa ett Bash- eller Python-skript som samlar in systemsäkerhetsstatus.
*   **Moment:**
    1.  Skriv ett skript som kontrollerar:
        *   Om det finns misslyckade SSH-inloggningsförsök i `/var/log/secure`.
        *   Status för `SELinux` (bör vara `Enforcing`).
        *   Diskutrymme på `/`.
    2.  Skapa ett cronjobb eller ett Ansible-jobb som kör detta skript en gång om dagen och sparar rapporten till en central loggfil på `rocky-mgmt`.

---

## 💡 Tips inför intervjun på Handelsbanken
*   **Bankmiljöer ställer höga krav på säkerhet:** Var beredd på att prata om hur du säkrar Linux-system (t.ex. SELinux, SSH-härdning, begränsade sudo-rättigheter).
*   **Spårbarshet (Audit):** Allt som görs i en bank måste loggas och kunna spåras. Bekanta dig med `auditd` (Linux Audit Daemon).
*   **Tänk "Infrastructure as Code" (IaC):** Framhäv att du inte konfigurerar servrar manuellt, utan att allt du gör dokumenteras och versionshanteras i Ansible-playbooks.
