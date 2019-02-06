########
# Copyright (c) 2014 GigaSpaces Technologies Ltd. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    * See the License for the specific language governing permissions and
#    * limitations under the License
import yaml
import logging
import ast
from jinja2 import Template

from . import LOGGER_NAME
from .exceptions import (
    NonRecoverableResponseException,
    RecoverableResponseException)

from pyFMG.fortimgr import FortiManager


logger = logging.getLogger(LOGGER_NAME)


#  request_props (port, ssl, verify, hosts )
def process(params, template, request_props):

    logger.debug(
        'process params:\n'
        'params: {}\n'
        'template: {}\n'
        'request_props: {}'.format(params, template, request_props))

    logger.debug('template type: \n {}'.format(type(template)))
    logger.debug('template: \n {}'.format(template))


    template_yaml = yaml.load(template)
    logger.debug('template_yaml: \n {}'.format(template_yaml))

    result_properties = {}

    for call in template_yaml['api_calls']:
        call_with_request_props = request_props.copy()

        logger.debug('call: \n {}'.format(call))

        # enrich params with items stored in runtime props by prev calls
        params.update(result_properties)

        template_engine = Template(str(call))
        rendered_call = template_engine.render(params)
        call = ast.literal_eval(rendered_call)  #unicode to dict

        logger.debug('rendered call: \n {}'.format(call))

        call_with_request_props.update(call)

        logger.info(
            'call_with_request_props: \n {}'.format(call_with_request_props))
        code, response = _send_request(call_with_request_props)
        logger.debug('---rrr--->: \n {}'.format(response))
        _process_response(code, response, call)

    return {call.get('response_translation', "response"): response}


def _send_request(call):
    logger.info(
        '_send_request request_props:{}'.format(call))
    host = call['host']
    username = call.get('username')
    password = call.get('password')
    use_ssl = call.get('use_ssl', False)
    verify_ssl = call.get('verify_ssl', False)

    url = call.get('path')
    data = call.get('data', {})
    method = call.get('method')

    fmg_instance = FortiManager(host,
                      username,
                      password,
                      debug=False,
                      use_ssl=use_ssl,
                      verify_ssl=verify_ssl,
                      disable_request_warnings=True)

    fmg_instance.login()

    if method == "GET":
        code, response = fmg_instance.get(url)
        logger.debug('---> Method: {} \n code: {} \n response: \n {}'.format(method, code, response))

    if method == "ADD":
        code, response = fmg_instance.add(url, **data)
        logger.debug('---> Method: {} \n code: {} \n response: \n {}'.format(method, code, response))

    if method == "UPDATE":
        code, response = fmg_instance.update(url, **data)
        logger.debug('---> Method: {} \n code: {} \n response: \n {}'.format(method, code, response))

    if method == "DELETE":
        code, response = fmg_instance.delete(url)
        logger.debug('---> Method: {} \n code: {} \n response: \n {}'.format(method, code, response))


        # if method == "UPDATE":
        # if method == "SET":
        # if method == "REPLACE":
        # if method == "CLONE":
    if method == "EXECUTE":
        code, response = fmg_instance.execute(url, **data)
        logger.debug('---> Method: {} \n code: {} \n response: \n {}'.format(method, code, response))

    fmg_instance.logout()
    return code, response


def _process_response(code, response, call):
    _check_response_status_code(code, response, call)
    if code != 0:
        if call.get('nonrecoverable_code', []):
            _check_response_expectations(response, call, is_recoverable=False)
        if call.get('recoverable_code', []):
            _check_response_expectations(response, call, is_recoverable=True)




def _check_response_status_code(code, response, call):
    response_code = code
    response_error_message = response
    nonrecoverable_codes = call.get('nonrecoverable_codes', [])
    recoverable_codes = call.get('recoverable_codes', [])

    if not response:
        return


    if response_code == 1:
        logger.debug('Response code: {}'.format(response_code))
        raise NonRecoverableResponseException(response_error_message)

    if response_code in nonrecoverable_codes:
        logger.debug('Non recoverable code found: {}'.format(response_code))
        raise NonRecoverableResponseException('nonrecoverable_code: {}'.format(response_code))

    if response_code in recoverable_codes:
        logger.debug('Recoverable code found: {}'.format(response_code))
        raise RecoverableResponseException('recoverable_code: {}'.format(response_code))


def _check_response_expectations( response, call, is_recoverable):
    response_content = response

    if is_recoverable:
        recoverable_code = call.get('recoverable_code', [])

        if not recoverable_code:
            return

        pattern = recoverable_code[:]
        pattern.pop(-1)

        response_value = _get_response_value(response_content, pattern)
        expected_value = recoverable_code[-1]

        if response_value is not expected_value:
            raise RecoverableResponseException(
                'Trying one more time...\n'
                'Response value:{0} does not match expected value: {1} '
                'from recoverable_code {2}'.format(str(response_value),
                                                   str(expected_value),
                                                   str(recoverable_code))
            )

    if not is_recoverable:
        nonrecoverable_code = call.get('nonrecoverable_code', [])

        if not nonrecoverable_code:
            return

        pattern = nonrecoverable_code[:]
        pattern.pop(-1)

        response_value = _get_response_value(response_content, pattern)
        expected_value = nonrecoverable_code[-1]

        if response_value is expected_value:
            raise NonRecoverableResponseException(
                'Giving up...\n'
                'Response value:{0} matches expected value: {1} '
                'from nonrecoverable_code {2}'.format(str(response_value),
                                                      str(expected_value),
                                                      str(nonrecoverable_code))
            )


def _get_response_value(response,
                        pattern,
                        raise_if_not_found=True):
    def str_list(li):
        return [str(item) for item in li]

    logger.debug('-->>>Response type: \n {}'.format(type(response)))
    logger.debug('-->>>Response : \n {}'.format(response))
    logger.debug('-->>>Pattern : \n {}'.format(pattern))

    value = response
    for p in pattern:
        if isinstance(value, dict):
            if p not in value:
                if raise_if_not_found:
                    raise KeyError(
                        'Key:{0} from pattern {1}'
                        'does not exist in response:{2}'.format(p,
                                                                str_list(pattern),
                                                                response)
                    )
                return None
            else:
                value = value[p]
        elif isinstance(value, list):
            try:
                value = value[p]
            except TypeError:
                raise TypeError(
                    'List item:{0} from pattern:{1}'
                    ' must be int but is:{2}'.format(p,
                                                     str_list(pattern),
                                                     type(p))
                )
            except IndexError:
                if raise_if_not_found:
                    raise IndexError(
                        'List index is out of range. Got {0} but '
                        'list size is {1}'.format(p, len(value))
                    )
                return None
        else:
            if raise_if_not_found:
                raise KeyError(
                    'Key does not exist'
                )
            return None

    return value
