import 'dart:io';
import 'dart:convert';

import 'CurlResponse.dart';

abstract class Curl
{
    static const int _TIMEOUT_NORMAL = 2000;

    static void curlJson(String url, void callback(CurlResponse response), [int timeout]) async
    {
        Uri uri = Uri.parse(Uri.encodeFull(url));

        var httpClient = new HttpClient();

        HttpClientResponse response;

        try
        {
            var request = await httpClient.getUrl(uri).timeout(new Duration(milliseconds: timeout ?? _TIMEOUT_NORMAL));
            request.followRedirects = true;
        }
        catch (error)
        {
            CurlResponse cresponse = new CurlResponse(
                responseCode: CurlResponse.UNKNOWN_ERROR,
                error: error.toString(),
                url: url,
            );

            callback(cresponse);
            return;
        }

        int statusCode = response.statusCode;
        String responseBody = await response.transform(new Utf8Decoder()).join();
        Map<String, dynamic> jsonBody;

        try
        {
            jsonBody = json.decode(responseBody);
        }
        catch (error)
        {
            CurlResponse cresponse = new CurlResponse(
                responseCode: statusCode,
                bodyRaw: responseBody,
                error: error.toString(),
                url: url,
            );

            callback(cresponse);
            return;
        }

        CurlResponse cresponse = new CurlResponse(
            responseCode: response.statusCode,
            bodyRaw: responseBody,
            json: jsonBody
        );

        callback(cresponse);
    }
}