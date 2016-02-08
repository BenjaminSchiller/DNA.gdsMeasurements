#!/usr/bin/python

#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: cde
# @Date:   2016-02-04 20:31:16
# @Last Modified by:   cde
# @Last Modified time: 2016-02-04 20:31:16

import re
import sys

def round_(function_string, digits):
    reg = r"([*]{2})(\d+)"
    function_string = re.sub(reg, r"^\2", function_string)
    numbers = extractdigits(function_string)
    floats = []
    for number in numbers:
        function_string = function_string.replace(number, "%."+str(digits)+"f", 1)
        floats.append(float(number))
    function_string = function_string % tuple(floats)
    print(function_string)


def extractdigits(string):
    reg = r"(?:^|[^^])(\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?"
    numbers = []
    for match in re.finditer(reg, string):
        string = match.group(0)
        #remove leading character if the wrong one got matched
        try:
            int(string[0])
        except:
            string = string[1:]
        numbers.append(string)
    return numbers
    

if __name__ == "__main__":
    round_(*sys.argv[1:])