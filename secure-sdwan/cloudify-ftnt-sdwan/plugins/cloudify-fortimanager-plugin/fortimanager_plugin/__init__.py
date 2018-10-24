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
#    * limitations under the License.

import logging
from cloudify import ctx as imported_ctx
from fortimanager_sdk import LOGGER_NAME as SDK_LOGGER_NAME


class CfyLogHandler(logging.Handler):
    """
    A logging handler for Cloudify.
    A logger attached to this handler will result in logging being passed
    through to the Cloudify logger.
    """

    def __init__(self, ctx):
        """
        Constructor.
        :param ctx: current Cloudify context, may be any type of context
                    (operation, workflow...)
        """
        logging.Handler.__init__(self)
        self.ctx = ctx

    def emit(self, record):
        """
        Callback to emit a log record.
        :param record: log record to write
        :type record: logging.LogRecord
        """
        message = self.format(record)
        self.ctx.logger.log(record.levelno, message)


handler = CfyLogHandler(imported_ctx)
logging.getLogger(SDK_LOGGER_NAME).setLevel(logging.DEBUG)
logging.getLogger(SDK_LOGGER_NAME).addHandler(handler)
