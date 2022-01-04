# -*- coding: utf-8 -*-
if __name__ == '__main__':
    import os
    import time
    import systemd.daemon
    import subprocess
    from influxdb import InfluxDBClient
    from datetime import datetime
    from PIL import Image, ImageDraw, ImageFont

    from board import SCK, MOSI, MISO, CE0, D24, D25, D4, D11, D5, D6
    from busio import SPI

    import ST7789 as TFT

    dir_path = os.path.dirname(os.path.realpath(__file__))


    def get_latest_alert():
        q = 'SELECT "alert_severity", "alert_signature", "dest_ip" FROM "alert" ORDER BY time DESC LIMIT 1'
        try:
            client = InfluxDBClient('127.0.0.1', 8086, '', '', 'suricata')
            r = client.query(q, raise_errors=False)
            for a in r.get_points():
                t = a.get('time').split('.')[0]
                s = a.get('alert_signature')
                if t and s:
                    return t, s
                else:
                    return '', ''
        except Exception as e:
            print(e)
            return '', ''

    def get_iface_ip_address(iface):
        cmd = "ifconfig %s | grep \"inet \" | awk '{print $2}'" % iface
        ip = subprocess.check_output(cmd, shell = True ).decode('utf-8').strip()
        if len(ip) < 1:
            return "not connected"
        return ip

    def get_temperature():
        cmd = "vcgencmd measure_temp"
        temp = subprocess.check_output(cmd, shell = True).decode('utf-8').split('=')[1].split("'")[0]
        return temp

    def get_rogue_ssid():
        cmd = "grep -E \"^\W*?ssid\" /etc/hostapd/hostapd.conf | cut -d '=' -f2"
        ssid = subprocess.check_output(cmd, shell = True ).decode('utf-8').strip()
        if len(ssid) < 1:
            return "not configured"
        return ssid

    def get_ssh_port():
        cmd = "grep -E \"^\W*?Port\" /etc/ssh/sshd_config | awk '{print $2}'"
        port = subprocess.check_output(cmd, shell = True ).decode('utf-8').strip()
        if len(port) < 1:
            return "not configured"
        return port

    def text_wrap(text, font, max_width):
            lines = []
            if font.getsize(text)[0]  <= max_width:
                lines.append(text)
            else:
                words = text.split(' ')
                i = 0
                while i < len(words):
                    line = ''
                    while i < len(words) and font.getsize(line + words[i])[0] <= max_width:
                        line = line + words[i]+ " "
                        i += 1
                    if not line:
                        line = words[i]
                        i += 1
                    lines.append(line)
            return lines


    RST = D5
    DC  = D6
    SPI_PORT = 0
    SPI_DEVICE = 0
    SPI_MODE = 0b11
    SPI_SPEED_HZ = 20000000
    spi = SPI(clock=SCK, MOSI=MOSI, MISO=MISO)
    disp = TFT.ST7789(spi=spi, rst=RST, dc=DC, spi_baudrate=SPI_SPEED_HZ)

    # Initialize display.
    disp.begin()

    # Clear display.
    disp.clear()
    systemd.daemon.notify('READY=1')

    while True:
        im = Image.open('/etc/pirogue/infos.bmp')
        font = ImageFont.truetype("/etc/pirogue/B612-Regular.ttf", 12)
        draw = ImageDraw.Draw(im)

        # Date & time
        now = datetime.now()
        draw.text((35, 13), now.strftime("%y/%m/%d %H:%M:%S"), font=font, fill=(21, 21, 21))

        # Temperature 
        draw.text((194, 13), get_temperature(), font=font, fill=(21, 21, 21))

        # eth0 IP  
        eth0_ip = get_iface_ip_address('eth0') 
        draw.text((35, 43), eth0_ip, font=font, fill=(21, 21, 21))

        # SSH  
        ssh_port = get_ssh_port()
        draw.text((35, 73), f'ssh -p{ssh_port} pi@{eth0_ip}', font=font, fill=(21, 21, 21))

        # Dashboard  
        draw.text((35, 103), f'http://{eth0_ip}:3000', font=font, fill=(21, 21, 21))

        # Rogue WiFi
        ssid = get_rogue_ssid()
        wlan0_ip = get_iface_ip_address('wlan0') 
        draw.text((35, 133), f'SSID: {ssid}', font=font, fill=(21, 21, 21))
        draw.text((35, 153), f'IP: {wlan0_ip}', font=font, fill=(21, 21, 21))

        # Alerts
        t = ''
        s = ''
        try:
            t, s = get_latest_alert()
        except:
            pass

        color = (247, 76, 72)
        draw.text((35, 178), f'{t}', font=font, fill=color)
        pos_y = 198
        inc = 15
        for i in text_wrap(s, font, 230):
            draw.text((5, pos_y), f'{i}', font=font, fill=color)
            pos_y += inc
        disp.display(image=im)

        time.sleep(0.2)
