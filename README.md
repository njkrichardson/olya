## Contents 
  1. [Background](https://github.com/njkrichardson/olya#background)
      1. [Why Arm?](https://github.com/njkrichardson/olya#why-arm?)
      2. [Untangling Terms: Architecture vs. Microarchitecture](https://github.com/njkrichardson/olya#untangling-terms-architecture-vs-microarchitecture)
      3. [Motivation](https://github.com/njkrichardson/olya#motivation)
  2. [Acknowledgements](https://github.com/njkrichardson/olya#acknowledgements)
  3. [References](https://github.com/njkrichardson/olya#references)
---

## Background 

The microprocessor is one of the most complex physical systems ever architected by humans. That said, while microprocessor design appears to be black magic to the unitiated, we are in the business of science and engineering. 

### Why Arm? 
I chose to implement [Arm](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/third-party/ddi0100e_arm_arm.pdf) [1] (rather than [x86\_64](https://en.wikipedia.org/wiki/X86-64), [SPARC](https://www.gaisler.com/doc/sparcv8.pdf), [MIPS](https://www.mips.com/products/architectures/), or [RISC-V](https://riscv.org/technical/specifications/), etc.) for two reasons. On one hand, Arm is a relatively clean and simple architecture, like MIPS or SPARC. On the other hand, Arm is a dominant commercial force, like Intel's x86\_64. 

Although Arm retains its RISC heritage in the modern versions (v8 and v9, at the time of this writing), the modern architecture standards are complex and much more idiosyncratic to meet demands for greater processor performance, security, and virtualization capabilities. With this in mind, we implement a processor which executes a subset of the Armv4 architecture, which is still the core foundation of the modern architectures. Importantly, architectures are more like dialects of the same language rather than distinct languages; once you know one, learning others is a relatively straightfoward project. 

An unfathomable number of bits of data are transformed, moved, and stored using Arm technologies. [Arm Ltd.](https://www.arm.com/) has shipped nearly 200 billion chips at the time of this writing, touching every corner of the computing landscape ranging 
from chips integrated into: network routers, mobile phones, embedded microcontrollers in cars and industrial equipment, aircraft, laptops, desktop computers, warehouse-scale computing 
servers, and supercomputers. Fujitsu's [Fugaku](https://www.fujitsu.com/global/about/innovation/fugaku/) supercomputer utilizes a custom Arm system on chip (SoC), for example. 

I feel confident that learning Arm is a practical investment in understanding the technology around you, and that once you start looking, you'll see chips all around you from your car to your headphones and everything in between. Statistically speaking, the vast majority of those chips implement the Arm architecture you'll learn in this guide, after all there are nearly twenty Arm chips per human on the planet. 

Generations into the future, twenty may seem a poor budget. Our descendents may have microprocessors embedded within the branches of their neural cell bodies. These cell bodies are nearly 10 microns across [4], with even current technology these cells could each  _geometrically_ contain a chip with thousands of transistors to help heal, augment, or virtualize our cognitive abilities. It's up to the neuroscientists and machine intelligence researchers could guide us in how to program them.


### Untangling Terms: Architecture vs. Microarchitecture

A computer **architecture** is an abstract machine which provides a model of computation for the programmer; it is comprised of an instruction set and operand locations. The instruction set 
is the set of operations the machine can execute, i.e., semantic descriptions of how state is changed resultant from issuing an operation in a program. Ultimately every program must reduce to 
a finite sequence with elements drawn from this minimal set of instructions. The operand locations describe where the operands manipulated by the instructions can be found (e.g., registers and memories). 

Most often, many different hardware (physical) implementations of an architecture exist. The specific topological arrangement of registers, memories, arithmetic units, and other 
building blocks is called its **microarchitecture**. Downstream from microarchitecture design, myriad fields of study focus their attention on the task of mapping this topological description into a physical arrangement of atoms. Once 
the desired positions of the atoms are specified, billions of dollars and thousands of hours are dedicated to put them there. In essence, transforming sand to gold. 

### Motivation 
In this guide you'll learn to think like a microarchitect. Microarchitects must command the hardware to obey the programmer's abstract machine model. Programmers ceaseslly demand more 
memory and shorter execution times for their programs, which forces microarchitects to play increasingly extreme games "under the covers", ultimately providing a clean Von Neumann illusion 
to the programmer. Hardware engineers and scientists bend and break assumptions in the underlying physics to provide microarchitects with ever more 
performant physical building blocks to construct their processors and memories. 

This guide is written for a curious programmer. Strictly speaking, she is (intellectually) shielded from the microarchitecture by the architecture. The set of programs one can run, and thus dream up, or even **synthesize**, is identical. 
But different points in the space of physical implementations incur real consequences. Programmers must begin to think in the context of threads and interconnect, the conventional 
Big O hammer obfuscates important realities. For instance: 
  * If matrix-multiplication and matrix inversion both require a number of operations which scales cubically with respect to problem size, 
why can we execute neural networks so fast but Gaussian Processes so slowly? 
  * If matrix-vector multiplication requires a number of operations which scales quadratically with respect to problem size, why is matrix-matrix multiplication 
preferred from an energy efficiency perspective? 
  * Why does the energy required to multiply two numbers scale quadratically with the precision of their encoding? 
  * Why does just **moving** state between distinct locations in space now dominate 
the energy consumption of a computer, rather than the seemingly more complex task of transforming that state? 

The _no free lunch theorem_ applies in hardware design, too, and is reflected in the modern trajectory of the industry (see, e.g., the most recent edition of Hennessy and Patterson [3]). That is, more and more attention is being 
directed to constructing machines which execute some programs exceptionally, in return for executing others poorly. Identifying the hypothesis space of programs of interest to 
your research or application thus translates to decisions in both software and hardware, when one approaches the frontiers and edges of computing as we know it. Gaining a deep understanding and an ability to make well-reasoned first principles inferences about the machines is invaluable(e.g., instruction/thread/data parallelism, memory systems, the physics of computing). 
My aim is to give you a view of what goes on beneath the covers of your machine, and a richer view of the interaction between algorithms and their
physical consequences in the traditional computing paradigm.

We've come a long way. The first commercially produced microprocessor, the [Intel 4004](https://en.wikipedia.org/wiki/Intel_4004), was released in 1971. The circuit 
is comprised of around 2,000 transistors, a clock rate of 750kHz (period 1.33us), built on a 10um technology node. In 2020, the [Apple M1](https://en.wikipedia.org/wiki/Apple_M1) was 
released, an Arm-based system on chip (SoC) with 16 billion transistors, a 3.2GHz clock rate (period 312ps), built on a 5nm node. 

Despite this compounded growth, unmatched by any other field in engineering, performance on a single thread appears to be stalling in recent years [3]; primarily resultant of 
the culmination of Moore's law and Dennard scaling (linear constant field scaling). Advances in high numerical aperture optics, material science, and transistor physics will 
tighten the last bits of slack in the line; but no matter how clever, transistors cannot be smaller than atoms. Blood in the water and an inflated economic environment has drawn 
sharks from all sides offering the next great panacea for computing performance: quantum, analog, thermodynamic, photonic, and biological computing paradigms, to name a few. The future is 
ours to build. Much of the theoretical underpinnings of this work can be completed from the safety of the laboratory; but changing the world with these technologies, and shifting 
the culture of the computing industry to amass the resources and cooperation to implement those ideas will demand a profound and deep understanding of computers as we know them. 

## Acknowledgements
The implementation is inspired by and draws from the processor architected in the Arm edition of Harris & Harris' _Digital Design and Computer Architecture_ [2], specifically following the chapter on 
microarchitecture and the hardware description language (HDL) modules provided in the accompanying site [2]. 

I actually had the good fortune to take David Harris' computer architecture course as an undergraduate math major at Harvey Mudd College. Although I left the course with a measely B+ grade and a confused understanding of computers, what David Harris demonstrated to me in those Monday and Wednesday morning hours was a gift I can't possibly repay: a man with the insane drive to truly understand a computer, from atoms to architectures.  

## References 
  [1] [Arm Architecture Reference Manual](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/third-party/ddi0100e_arm_arm.pdf)
  
  [2] [Harris, David M., and Sarah Harris. Digital Design and Computer Architecture. 4th ed., Elsevier Science &amp; Technology, 2015.](https://www.elsevier.com/books/digital-design-and-computer-architecture-arm-edition/harris/978-0-12-800056-4)
  
  [3] [Hennessy, John L., and David A. Patterson. Computer architecture: a quantitative approach. Elsevier, 2011.](https://www.elsevier.com/books/computer-architecture/hennessy/978-0-12-811905-1)
  
  [4] [Fiala, John C., and Harris, Kristen M. Dendritic Structure. Oxford University Press, 1999.](https://synapseweb.clm.utexas.edu/dimensions-dendrites)
