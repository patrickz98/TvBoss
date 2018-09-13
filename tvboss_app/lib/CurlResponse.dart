class CurlResponse
{
    static const UNKNOWN_ERROR = -1;
    static const NOTHING_SELECTED = -2;

    final int responseCode;
    final Map<String, dynamic> json;

    final String error;
    final String url;

    // debug
    final String bodyRaw;

    CurlResponse({
        this.responseCode,
        this.error,
        this.url,
        this.json,
        this.bodyRaw,
    });

    bool failed()
    {
        return json == null;
    }
}