
if __name__ == '__main__':
    import systemd.daemon
    import datetime
    from nfstream import NFStreamer
    from influxdb import InfluxDBClient
    import geoip2.database

    db = 'flows'
    client = InfluxDBClient('127.0.0.1', 8086, '', '', db)
    client.create_database(db)
    client.create_retention_policy(f'{db}_5d', '5d', 1, database=db, default=True)

    online_streamer = NFStreamer(source="wlan0")
    reader = geoip2.database.Reader('/etc/pirogue/GeoLite2-City.mmdb')

    systemd.daemon.notify('READY=1')

    for flow in online_streamer:
        try:
            obj = {
                'measurement': 'flow',
                'tags': {
                    'application_name': flow.application_name,
                    'application_category_name': flow.application_category_name
                },
                'time': datetime.datetime.fromtimestamp(flow.bidirectional_first_seen_ms/1000.0).astimezone().isoformat(),
                'fields': {
                    'bidirectional_duration_ms': flow.bidirectional_duration_ms,
                    'bidirectional_bytes': flow.bidirectional_bytes,

                    'src_ip': flow.src_ip,
                    'src_mac': flow.src_mac,
                    'src_port': flow.src_port,

                    'dst_ip': flow.dst_ip,
                    'dst_mac': flow.dst_mac,
                    'dst_port': flow.dst_port,

                    'application_name': flow.application_name,
                    'application_category_name': flow.application_category_name,

                    'requested_server_name': flow.requested_server_name,

                    'value': 1
                }
            }

            try:
                response = reader.city(flow.dst_ip)
                obj['fields']['country'] = response.country.name
                obj['fields']['country_iso'] = response.country.iso_code
                obj['fields']['city'] = response.city.name
                obj['fields']['latitude'] = response.location.latitude
                obj['fields']['longitude'] = response.location.longitude
            except Exception:
                pass
            client.write_points([obj], database=db)
        except Exception as e:
            print(e)

    systemd.daemon.notify('STOPPING=1')
    