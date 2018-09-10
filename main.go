package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

type EpgData struct {
	EventId int
	EpisodeId int
	ChannelName string
	ChannelUuid string
	ChannelNumber string
	Start int64
	Stop int64
	Title string
	Subtitle string
	Summary string
	Description string
	Widescreen int
	Genre []int
	NextEventId int
}

type Epg struct {
	TotalCount int
	Entries []EpgData
}

type EpgInfo struct {
	Title string
	Subtitle string
	Summary string
	Description string
	ChannelName string
	Start time.Time
	Stop time.Time
	Info map[string][]string
}

func main() {
	// resp, err := http.Get("http://overdvb-c.local:9981/api/epg/content_type/list")
	// resp, err := http.Get("http://overdvb-c.local:9981/api/epg/events/grid")
	// resp, err := http.Get("http://overdvb-c.local:9981/api/epg/events/grid?limit=23407")
	resp, err := http.Get("http://overdvb-c.local:9981/api/epg/events/grid?limit=24001")

	if err != nil {
		panic(err)
	}

	defer resp.Body.Close()

	tvhBytes, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		panic(err)
	}

	var epg Epg
	err = json.Unmarshal(tvhBytes, &epg)

	if err != nil {
		panic(err)
	}

	fmt.Println("TotalCount", epg.TotalCount)
	fmt.Println("Length:", len(epg.Entries))

	dataBase := make(map[string][]EpgInfo)
	channels := make(map[string]string)

	for inx := range epg.Entries {
		epgEntry := epg.Entries[ inx ]

		info := make(map[string][]string)

		regex := regexp.MustCompile("([A-Z]\\w+): (.*?)?(\\n)")
		res := regex.FindAllStringSubmatch(epgEntry.Description, -1)

		for inx := range res {
			key := res[ inx ][ 1 ]

			if len(res[ inx ][ 2 ]) < 50 {
				info[ key ] = strings.Split(res[ inx ][ 2 ], ", ")
			}
		}

		// if len(info) == 0 {
		// 	continue
		// }

		start := time.Unix(epgEntry.Start, 0)
		stop := time.Unix(epgEntry.Stop, 0)
		date := start.Format("2006-01-02")

		epgInfo := EpgInfo{}
		epgInfo.Title = epgEntry.Title
		epgInfo.Description = epgEntry.Description
		epgInfo.ChannelName = epgEntry.ChannelName
		epgInfo.Start = start
		epgInfo.Stop = stop
		epgInfo.Info = info

		channelName := strings.Replace(epgEntry.ChannelName, "/", "_", -1)
		channelName = strings.Replace(channelName, " ", "_", -1)

		channels[ epgInfo.ChannelName ] = channelName

		key := date + "-" + channelName

		if val, ok := dataBase[ key ]; ok {
			dataBase[ key ] = append(val, epgInfo)
		} else {
			dataBase[ key ] = []EpgInfo{epgInfo}
		}

		// bytes, _ := json.Marshal(epgInfo)
		// bytes, _ := json.MarshalIndent(epgInfo, "", "\t")
		// fmt.Println(string(bytes))
	}

	for key, value := range dataBase {
		year := key[:4]
		month := key[5:7]
		day := key[8:10]
		channel := key[11:]

		path := "v1/" + year + "/" + month + "/" + day + "/"
		os.MkdirAll(path, os.ModePerm)

		jsonBytes, _ := json.MarshalIndent(value, "", "\t")
		err := ioutil.WriteFile(path + channel + ".json", jsonBytes, 0644)

		if err != nil {
			panic(err)
		}
	}

	channelsBytes, _ := json.MarshalIndent(channels, "", "\t")
	ioutil.WriteFile("v1/channel-index.json", channelsBytes, 0644)
}
