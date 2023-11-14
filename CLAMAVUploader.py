@app.route('/upload_file', methods=['POST'])

def upload_file():
    status = 200
    response = {}
    try:
       
        file = request.files['testfile']
        cd = clamd.ClamdNetworkSocket()
        cd.__init__(host='localhost', port=3310, timeout=None)
        scan_result = cd.instream(file)
        
        if (scan_result['stream'][0] == 'OK'):
            message = 'file has no virus)
            print(scan_result['stream'])
	        file.seek(0)
            # <write the code to save file in local or push file to remote storage>
        elif (scan_result['stream'][0] == 'FOUND'):
            message = 'file has virus'
            print(scan_result['stream'])
        else:
            message = 'Error occured while processing'
        response['message'] = message
    except Exception as exp:
        print(traceback.format_exc())
        status = 500
        response['code'] = 500
        response['message'] = str(exp)
    return response, status