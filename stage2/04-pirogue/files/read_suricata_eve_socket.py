import json
import os
import socket
from collections.abc import MutableMapping

from influxdb import InfluxDBClient

socket_path = '/tmp/suri.sock'


def _flatten_dict_gen(d, parent_key, sep):
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, MutableMapping):
            yield from flatten_dict(v, new_key, sep=sep).items()
        else:
            yield new_key, v


def flatten_dict(d: MutableMapping, parent_key: str = '', sep: str = '_'):
    return dict(_flatten_dict_gen(d, parent_key, sep))


def convert_to_influxdb_format(eve_obj):
    eve_obj = flatten_dict(eve_obj)
    obj = {
        'measurement': 'alert',
        'tags': {
            'event_type': eve_obj.get('event_type'),
            'proto': eve_obj.get('proto'),
            'src_ip': eve_obj.get('src_ip'),
            'dest_ip': eve_obj.get('dest_ip')
        },
        'time': eve_obj.get('timestamp'),
        'fields': {
            'value': 1
        }
    }
    for k, v in eve_obj.items():
        if type(v) == str:
            obj['fields'][k] = v
        else:
            obj['fields'][k] = v
    return obj


if __name__ == '__main__':
    import systemd.daemon
    buf_size = 4096
    if os.path.exists(socket_path):
        os.remove(socket_path)
    db = 'suricata'
    client = InfluxDBClient('127.0.0.1', 8086, '', '', db)
    client.create_database(db)
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(socket_path)
    server.listen(1)
    systemd.daemon.notify('READY=1')
    while True:
        try:
            conn, _ = server.accept()
            data = conn.recv(buf_size)
            event = data
            while len(data) == buf_size:
                data = conn.recv(buf_size)
                event += data
            decoded_events = event.decode('utf-8').strip()
            suricata_events = []
            for event in decoded_events.split('\n'):
                json_obj = json.loads(event)
                suricata_event = convert_to_influxdb_format(json_obj)
                suricata_events.append(suricata_event)
            client.write_points(suricata_events, database=db)
            print(suricata_events)
        except Exception as e:
            print(e)
            
    server.close()

    systemd.daemon.notify('STOPPING=1')

    if os.path.exists(socket_path):
        os.remove(socket_path)
