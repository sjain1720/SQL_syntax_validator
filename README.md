# compiler_design
**Project Title: SQL Syntax Validator**


**Project Description:**
The SQL Syntax Validator is a powerful tool developed using Flex and Yacc, designed to validate the syntax of multiple SQL queries. It offers detailed error reporting, indicating the query number and column index where syntax errors occur, thus enhancing the reliability of your database queries and simplifying the debugging process.


**Installation:**
To run this project, you'll need to have the following software installed on your computer

1. Flex: Flex (Fast Lexical Analyzer) is a tool for generating lexical analyzers. You can download it from Flex's official website or install it using your system's package manager.

2. Bison: Bison is a parser generator that complements Flex. You can download it from Bison's official website or install it using your system's package manager.

Ensure that both Flex and Bison are properly installed on your system before using this SQL compiler.


**Usage:**
To use this SQL compiler, follow these steps:

1. **Compilation**:
   - Compile the Flex and Yacc source files to generate the executable file. You can do this by running the following commands:
   
   ```shell
   flex -o lex.yy.c cd_project.l
   bison -d -o parser.tab.c cd_project.y
   gcc -o sql_compiler lex.yy.c parser.tab.c -lfl
   ```

2. **Execution**:
   - After compilation, you can run the SQL compiler by executing the resulting executable file:

   ```shell
   ./sql_compiler
   ```

3. **Customizing Input**:
   - To customize the input SQL queries, you can edit the `test_cases.sql` file. Replace or modify the queries within this text file to validate different SQL statements.


**Features:**

1. **Syntax Validation**: The SQL compiler rigorously validates the syntax of SQL queries, ensuring compliance with SQL standards.

2. **Detailed Error Reporting**: When syntax errors are detected, the compiler provides precise error messages, indicating the query number and column index where issues occur for efficient debugging.

3. **Support for Multiple Queries**: The compiler is designed to handle batches of SQL queries, making it a valuable tool for processing multi-query scripts.

4. **Enhanced Debugging**: The compiler offers an enhanced debugging experience, with clear and informative error messages to facilitate swift issue resolution.

5. **Flex and Bison Integration**: This project leverages Flex and Bison for lexical analysis and parsing, enabling robust and efficient syntax validation.

6. **Platform Compatibility**: The SQL compiler is platform-agnostic, ensuring it functions seamlessly across various operating systems.

7. **Performance**: The compiler is optimized for performance, delivering rapid syntax validation even with complex or large SQL queries.

8. **Customization**: Users have the flexibility to customize and extend the compiler according to their specific needs and use cases.

9. **Usage Examples**: Comprehensive usage examples are provided in the documentation to guide users in effectively utilizing the SQL compiler.

10. **Scalability**: The compiler gracefully handles extensive and intricate SQL queries, maintaining reliable syntax validation for all query complexities.
