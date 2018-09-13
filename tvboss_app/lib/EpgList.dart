import 'dart:convert';

class EpgData
{
    final String Title;
    final String Subtitle;
    final String Summary;
    final String Description;
    final String ChannelName;
    final DateTime Start;
    final DateTime Stop;
    final Map<String, List<String>> Info;

    EpgData({
        this.Title,
        this.Subtitle,
        this.Summary,
        this.Description,
        this.ChannelName,
        this.Start,
        this.Stop,
        this.Info,
    });

    static EpgData parse(Map<String, dynamic> data)
    {
        DateTime start = DateTime.parse(data[ "Start" ]);
        DateTime stop = DateTime.parse(data[ "Stop" ]);

        Map<String, dynamic> info = data[ "Info" ];
        Map<String, List<String>> map = new Map();

        info.forEach((String key, dynamic entry)
        {
            List<String> list = [];

            List<dynamic> tmp = entry;

            tmp.forEach((dynamic val)
            {
                list.add(val);
            });


            map[ key ] = list;
        });

        return EpgData(
            Title: data[ "Title" ],
            Subtitle: data[ "Subtitle" ],
            Summary: data[ "Summary" ],
            Description: data[ "Description" ],
            ChannelName: data[ "ChannelName" ],
            Start: start,
            Stop: stop,
            Info: map,
        );
    }
}

class EpgList
{
    final List<EpgData> entries;

    EpgList(this.entries);

    static EpgList parse(String json)
    {
        List<dynamic> epgList = jsonDecode(json);

        List<EpgData> list = [];

        epgList.forEach((dynamic entry)
        {
            EpgData data = EpgData.parse(entry);
            list.add(data);
        });

        return EpgList(list);
    }
}