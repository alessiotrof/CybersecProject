import clamd
import traceback

#In caso si rendesse il servizio di CLAMAV esterno, test tramite python
def upload_file(file):
    status = 200
    response = {}
    try:
        cd = clamd.ClamdNetworkSocket()
        cd.__init__(host='127.0.0.1', port=3310, timeout=None)
        scan_result = cd.instream(file)
        
        if scan_result['stream'][0] == 'OK':
            message = 'Il file non contiene virus'
            print(scan_result['stream'])
            file.seek(0)
            # <inserire qui il codice per salvare il file in locale o inviarlo a uno storage remoto>
        elif scan_result['stream'][0] == 'FOUND':
            message = 'Il file contiene un virus'
            print(scan_result['stream'])
        else:
            message = 'Si è verificato un errore durante l\'elaborazione'
        response['message'] = message
    except Exception as exp:
        print(traceback.format_exc())
        status = 500
        response['code'] = 500
        response['message'] = str(exp)
    return response, status

# Esempio di utilizzo:
if __name__ == "__main__":
    try:
        # Carica un file (devi sostituire questo con il modo in cui ottieni il file)
        with open('./LICENSE', 'rb') as file_to_scan:
            response, status = upload_file(file_to_scan)
            print(response, status)
    except FileNotFoundError:
        print("File non trovato")