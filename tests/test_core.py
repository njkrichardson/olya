import argparse 
from functools import partial 
import os 
from typing import Union 

from tabulate import tabulate 

Path = Union[os.PathLike, str] 

parser = argparse.ArgumentParser(description="This script can be used to test the microprocessor implementations.\
                                              The test loads a short program into the instruction memory (starting \
                                              nominally at address 0x00), and executes the program, confirming that \
                                              the final state corresponds to the desired behavior. This script \
                                              compiles the necessary hardware modules (including the testbench), \
                                              and executes the test.")
parser.add_argument("--verbose", action="store_true")
#iverilog -g2005-sv controller.sv conditional_logic.sv ../../hardware_utils/utils.v decoder.sv datapath.sv core.sv ../../hardware_utils/alu.sv ../../hardware_utils/state.sv ../../tests/testbench.sv ../../tests/top.sv

def get_project_root() -> Path: 
    _file_path: Path = os.path.abspath(__file__)
    testing_directory_path: Path = os.path.dirname(_file_path) 
    return os.path.dirname(testing_directory_path)

def main(args): 
    root_path: Path = get_project_root() 

    # --- load and display the test program (if we're running in verbose mode)
    if args.verbose: 
        program_path: Path = os.path.join(root_path, "programs/basic.dat")
        print("Displaying the test program: ")
        os.system(f"bat {program_path}")

    
    root_join: callable = partial(os.path.join, root_path)

    # basepath module names 
    processor_modules: list = ["core", "datapath", "controller", "decoder", "conditional_logic"]
    hardware_utility_modules: list = ["alu", "combinational_logic", "state"]
    testbench_modules: list = ["testbench", "top"]

    # module paths 
    processor_modules_paths = [root_join("processors/single_cycle/" + module + ".sv") for module in processor_modules]
    hardware_utility_modules_paths = [root_join("hardware_utils/" + module + ".sv") for module in hardware_utility_modules]
    testbench_modules_paths = [root_join("tests/" + module + ".sv") for module in testbench_modules]

    if args.verbose: 
        table = list(zip(processor_modules, processor_modules_paths)) + \
                list(zip(hardware_utility_modules, hardware_utility_modules_paths)) + \
                list(zip(testbench_modules, testbench_modules_paths))

        print(tabulate(table, headers=["Module name", "Path"]))

    # this is required to set the correct absolute path for the instruction memory 
    state_module_path = hardware_utility_modules_paths[-1] 
    with open(state_module_path, 'r') as file:
        filedata = file.read()

    filedata = filedata.replace("REPLACEME", f"{program_path}")

    with open(state_module_path, 'w') as file:
        file.write(filedata)

    # compile the top level testbench with dependencies 
    compiler = "iverilog"
    compiler_flags = "-g2005-sv"
    output = root_join("tests/test_out")
    print("Compiling the processor and associated modules")
    os.system(f"{compiler} {compiler_flags} -o {output} {' '.join(processor_modules_paths)} {' '.join(hardware_utility_modules_paths)} {' '.join(testbench_modules_paths)}")
    print("Running compiled test ouput...")
    os.system(f"{output}")

if __name__=="__main__": 
    args = parser.parse_args() 
    if args.verbose: 
        print("Running in verbose mode...")
    main(args) 
