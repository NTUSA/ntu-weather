<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="http://overpass-30e2.kxcdn.com/overpass.css" />
    <link rel="stylesheet" href="https://rschiang.github.io/ntu-weather/assets/normalize.min.css" />
    <link rel="stylesheet" href="https://rschiang.github.io/ntu-weather/assets/chartist.min.css" />
    <link rel="stylesheet" href="https://rschiang.github.io/ntu-weather/assets/weather.css" />
    <script src="https://rschiang.github.io/ntu-weather/assets/chartist.min.js"></script>
    <script src="https://rschiang.github.io/ntu-weather/assets/chartist-plugin-pointlabels.min.js"></script>

    <title>天氣 – 國立臺灣大學, 台灣</title>
    <meta name="description" content="究竟公館現在有沒有在下雨呢？臺大即時氣象資訊（氣溫、風向、氣壓、降雨），讓第 28 屆臺大學生會福利部告訴你！" />
    <meta property="og:site_name" content="臺大學生會" />
    <meta property="og:title" content="國立臺灣大學, 台灣 — NTUSA 氣象" />
    <meta property="og:image" content="https://rschiang.github.io/ntu-weather/assets/social.jpg" />
    <meta property="og:url" content="http://weather.ntustudents.org" />

    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
        ga('create', 'UA-79166280-1', 'auto');
        ga('send', 'pageview');
    </script>
<%
    def value(text, default='N/A'):
        try:
            float_value = float(text)
            return round(float_value)
        except ValueError:
            return default
        end
    end

    def dec_value(text, default='N/A'):
        try:
            float_value = round(float(text), 1)
            if float_value < 0.1:
                return 0
            else:
                return float_value
            end
        except ValueError:
            return default
        end
    end
%>
</head>
<body>
    <header class="section">
        <img alt="國立臺灣大學學生會" class="vendor logo" src="http://rschiang.github.io/ntu-weather/assets/logo.png" />
    </header>
    <section class="weather">
        <div class="section">
            <h3>國立臺灣大學, 台灣</h3>
% if defined('error'):
            <div class="temperature">
                <span class="current">--</span>
                <span class="unit">--</span>
            </div>
            <div class="dashboard">
                <ul>
                    <li>資訊暫時無法使用。</li>
                </ul>
            </div>
% else:
            <div class="temperature">
                <span class="current">{{ value(temperature, default='--') }}</span>
                <span class="unit">°C</span>
            </div>
            <div class="dashboard">
                <ul>
                    <li>本日氣溫 <em>{{ value(temp_min) }} – {{ value(temp_max) }} °C</em></li>
                    <li>風向 <span class="wind" style="transform: rotate({{ dec_value(wind_direction, default=0) - 90 }}deg)">➤</span> <em>{{ dec_value(wind_speed) }} m/s</em></li>
                    <li>氣壓 <em>{{ dec_value(pressure) }} hPa</em></li>
                    <li>降雨強度 <em>{{ dec_value(rain) }} mm/h</em></li>
                    <li>濕度 <em>{{ dec_value(humidity) }}%</em></li>
                    <li>本日降雨 <em>{{ dec_value(rain_day) }} mm</em></li>
                </ul>
            </div>
            <div class="chart">
                <div class="ct-chart" id="daily-chart"></div>
            </div>
            <div class="source">
                資料來源：{{ provider }}（最後更新：{{ date.strftime('%m/%d %H:%M') }}）
            </div>
% end
        </div>
    </section>
    <footer class="section">
        <div class="social">
            <iframe src="https://www.facebook.com/plugins/like.php?href=https%3A%2F%2Fwww.facebook.com%2FNTUWelfare&width=92&layout=button_count&action=like&show_faces=false&share=false&height=21&appId=599411893573946" width="92" height="21" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>
            <iframe src="https://www.facebook.com/plugins/share_button.php?href=http%3A%2F%2Fweather.ntustudents.org%2F&layout=button&mobile_iframe=true&appId=599411893573946&width=58&height=21" width="58" height="21" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>
        </div>
        <div class="meta">
            第 28 屆<a href="https://www.facebook.com/NTUWelfare" rel="external nofollow">國立臺灣大學學生會福利部</a>
            <span class="hide">「總是為你撐起一把傘。」</span><br />
            National Taiwan University Student Association, 2016
        </div>
    </footer>

<%
    labels = []
    series = []
    for data in daily:
        pm = data['date'].hour >= 12
        hour = data['date'].hour % 12
        if hour == 0:
            labels.append('"12pm"' if pm else '"12am"')
        else:
            labels.append('"{}{}"'.format(hour, 'pm' if pm else 'am'))
        end

        if not 'error' in data:
            series.append(str(value(data['temperature'])))
        else:
            series.append('NaN')
        end
    end
%>
    <script>
        var data = {
            labels: [ {{! ', '.join(labels) }} ],
            series: [
                [ {{! ', '.join(series) }} ]
            ]
        };

        var options = {
            axisX: { labelOffset: { x: -15, y: 0 } },
            axisY: { showLabel: false, showGrid: false },
            fullWidth: true, high: 40, low: 0,
            plugins: [ Chartist.plugins.ctPointLabels({ labelClass: 'ct-datalabel' })],
            showArea: true,
        };

        new Chartist.Line('#daily-chart', data, options);
    </script>
</body>
</html>
