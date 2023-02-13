Python Grammar in Silver
========================

STEPS FOR RUNNING THE PYTHON GRAMMAR

1. Install Silver via the instructions on Silver's website: 
   https://melt.cs.umn.edu/silver/install-guide/

2. Clone the "python-silver-grammar" repository which contains "edu.umn.cs.melt.python/" which includes Main.sv, Python.sv, silver-compile, and PythonTest.py
 
3. Within "edu.umn.cs.melt.python/", type "./silver-compile" and hit enter. A ".jar" file will be generated. This will be referred to as $JAR.

4. Type "java -jar $JAR PythonTest.py" to run the test file


For more information on our work with layout-sensitive parsing, see:
http://www-users.cs.umn.edu/~hall/research_paper_in_markdown.html

We ran our Python implementation on test files found at http://code.google.com/p/shedskin/. For more information on how we used the test files, see: 
http://www-users.cs.umn.edu/~hall/research_paper_in_markdown.html
