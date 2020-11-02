# -*- coding: utf-8 -*-
import ast
import base64

def test(event, context):
    """ Initial run function called by cloud function
        Keyword arguments:
        id -- the id for the job
        type -- name of the cloud function
    """

    try:
        if 'data' in event:
            data_decoded = base64.b64decode(event['data'])
            data_dic = ast.literal_eval(data_decoded.decode('utf-8'))
            print("DATA:", data_dic)

        else:
            raise Exception('Error in data in from coordinator.')
    except Exception as e:
        print("Error while running main function: +++++ ", e, " +++++")
