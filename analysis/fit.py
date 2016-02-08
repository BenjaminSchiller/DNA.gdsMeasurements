#!/usr/bin/python

# -*- coding: utf-8 -*-
"""
Created on Tue Jan 26 14:55:42 2016

@author: cde
"""

from scipy.optimize import curve_fit
import sys
import os
import pandas
import numpy as np
import json

base_dir = os.path.dirname(__file__)
function_config_path = os.path.join(base_dir, "fit.cfg")
file_config_path = os.path.join(base_dir, "config.sh")


debug = True

variance = "var"
median = "med"
average = "avg"
size = "size"
quiet = "quiet"
valid_args = [variance, median, average, quiet]
column_args = [median, average]
standard_col = average
column_index = {size: 1, average: 2, median: 5}
column_names = ["size", "avg", "min", "max", "med", "var", "varLow", "varUp"]


def main(aggr, col_index, data_type, size, parallel, data_structure):
    """
    build required directory and find .aggr files
    """
    config = file_config(file_config_path)

    data_path = os.path.join(base_dir, config.data_dir, data_type, size, parallel, data_structure)

    fit_path = os.path.join(base_dir, config.fit_dir + "-" + col_index, data_type, size, parallel, data_structure)
    if not os.path.exists(fit_path):
        os.makedirs(fit_path)

    var = False
    index = int(col_index)
    if index > 0:
        var = True
    index = np.abs(index)
    if index > 100:
        index = index - 100
    column = column_names[index]

    if os.path.exists(data_path) and os.path.isdir(data_path):
        dirlist = os.listdir(data_path)
        for path in dirlist:
            if not path.endswith("." + aggr):
                continue
            data_file = os.path.join(data_path, path)
            try:
                regress_file(data_file, fit_path, var=var, column=column)
            except:
                if debug:
                    print("the following file could not be processed: " + data_file)
                    print("error: " + str(sys.exc_info()[0]))
                    raise
    else:
        raise ValueError("supplied data file path does not exist: " + data_path)




def regress_file(file_path, fit_path, var=False, column="avg"):
    """
    fit the data of the supplied file to all functions written in the
    config file "fit.cfg"
    """
    usevar = var
    write_output = False
    data = __data(file_path)
    functions = __parse_functions(function_config_path)
    sigma = None
    if usevar:
        # sigma is standard deviation = root of variance
        sigma = np.sqrt(data.get(variance)).tolist()

    optimal_functions = fit_data(data, functions, sigma, column)
    # order function keys according to error
    sorted_functions = sorted(optimal_functions.keys(),
                              key=lambda key: np.abs(optimal_functions[key]["avg_res"]))
    filename = os.path.basename(file_path).rsplit(".", 1)[0]
    fit_file_path = os.path.join(fit_path, filename)
    function_file = open(fit_file_path + ".functions", 'w')
    log_file = open(fit_file_path + ".log", 'w')
    for function in sorted_functions:
        function_file.write("%s %s\n" % (optimal_functions[function]["avg_res"], get_function_string(functions[function], optimal_functions[function]["popt"])))
        json.dump(optimal_functions[function], log_file)


def fit_data(data, functions, sigma, column):
    # use size column as x values
    xdata = data.get(size)
    ydata = data.get(column)
    optimal_functions = {}
    absolute = False
    if sigma is not None:
        absolute = True

    for function_name in functions:
        # get variable names
        function_string = functions[function_name]
        function = __get_function(function_string)
        popt, pcov, infodict, errmsg, ier = curve_fit(function, xdata, ydata,
            sigma=sigma, absolute_sigma=absolute, full_output=True)
        optimal_functions[function_name] = {}
        optimal_functions[function_name]["popt"] = popt.tolist()
        optimal_functions[function_name]["pcov"] = pcov.tolist()
        optimal_functions[function_name]["fvec"] = infodict["fvec"].tolist()
        optimal_functions[function_name]["pvar"] = np.sqrt(np.diag(pcov)).tolist()
        optimal_functions[function_name]["avg_res"] = np.mean(np.abs(infodict["fvec"])).item()
    return optimal_functions


def __get_function(func_string):
    variables = get_betavalues(func_string)
    var_string = ""
    for variable in variables:
        var_string += ", " + variable
    lambda_string = "lambda x%s: eval('%s')" % (var_string,
        replace_scipy_functions(func_string))
    function = eval(lambda_string)
    return function


def get_function_string(raw_string, ordered_variables):
    function_string = raw_string
    variables = get_betavalues(function_string)
    if len(variables) != len(ordered_variables):
        raise ValueError("not the right number of variables: %s != %s" % (str(len(ordered_variables)), str(len(variables))))
    for variable in variables:
        function_string = function_string.replace(variable, "%s", 1)
    function_string = function_string % tuple(ordered_variables)        
    return function_string


def __parse_functions(config_location):
    config = open(config_location, 'r')
    # key is function name, value is (polynomial) function string
    function_map = {}
    for line in config:
        line = line.strip()
        # check if line is empty or comment
        if not line or line.startswith('#'):
            continue
        function = line.split('=')
        # check for valid format
        if len(function) != 2:
            raise ValueError("invalid format in config file: " + line)
        else:
            function_map[function[0].strip()] = function[1].strip()
    return function_map



class file_config():

    def __init__(self, config_location):
        self.config_location = config_location
        self.__parse_config(config_location)

    def __parse_config(self, config_location):
        try:
            config = open(config_location, 'r')
            for line in config:
                if line.startswith("aggrDir") and len(line.split("=")) == 2:
                    self.data_dir = line.split("=")[1].replace('"', "").strip()
                elif line.startswith("aggrFitDir") and len(line.split("=")) == 2:
                    self.fit_dir = line.split("=")[1].replace('"', "").strip()
                else:
                    continue
        except:
            print("warning: could not process config file, using default data directories")
            self.data_dir = "data/aggr"
            self.fit_dir = "data/aggrFits"



class __data():
    # pseudo wrapper around pandas
    def __init__(self, filename):
        self.filename = filename
        datafile = open(filename, 'r')
        pandas_header = 0
        for line in datafile:
            if line.strip() == "" or line.strip().startswith("#"):
                pandas_header += 1
                continue
            elif line.strip().startswith("size"):
                self.data = pandas.read_table(filename, delim_whitespace=True, header=pandas_header, escapechar="#")
                break
            elif line.strip().startswith("1"):
                self.data = pandas.read_table(filename, delim_whitespace=True, names=column_names, escapechar="#")
                break
            else:
                raise ValueError("invalid data: " + line)

    def get(self, column):
        try:
            return self.data.get(column)
        except:
            raise ValueError("unknown data, check format")

#-----------------------------------regress methods

# -*- coding: utf-8 -*-
"""
Created on Fri Jan 22 09:49:18 2016

@author: cde
"""

import re

scipy_functions = {"log":"np.log"}

def get_betavalues(func_string):
    """
    get all adjustable parameters from the string, in this case any single
    alphabetic character except x, y and z followed by any number of digits
    """
    #remove function calls, otherwise they will be interpreted as parameters
    local_func = func_string
    functions = __get_functions(func_string)
    for function in functions:
        local_func = local_func.replace(function, "")
    #extract the parameters
    match = re.compile("([a-w][0-9]*)")
    variables = match.findall(local_func)
    return variables

def beautify_function(func_string):
    pretty_string = func_string.strip()
    pretty_string = re.sub("(\s*\*\*\s*)", "^", pretty_string)
    pretty_string = re.sub("(\s*\*\s*)", "", pretty_string)
    return pretty_string


def __get_functions(func_string):
    """
    extract anything from the string that could be interpreted as a (python) function
    """
    match = re.compile("([a-zA-Z.]+)\(.*\)")
    functions = match.findall(func_string)
    return functions

def get_scipy_function(function):
    """
    for the given gnuplot function return a function that scipy can interpret
    """
    if function in scipy_functions:
        return scipy_functions[function]
    else:
        #bandaid, TODO
        return "np." + function


def replace_scipy_functions(func_string):
    functions = __get_functions(func_string)
    for function in functions:
        func_string = func_string.replace(function, get_scipy_function(function))
    return func_string


#end regress methods ----------------------------




if __name__ == "__main__":
    #"/home/cde/data/DNA/aggr/Edge/1000/10000/DHashArrayList/SIZE.aggr"
    # main("aggr", "102", "Edge", "1000", "10000", "DHashArrayList")
    main(*sys.argv[1:])
