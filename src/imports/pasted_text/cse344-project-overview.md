1
CSE344: SOFWARE ENGINEERING
YEDITEPE UNIVERSITY
Instructor: Prof. Dr. Mert Ozkaya
SPRING 2026 TERM PROJECT
This semester you are required to undertake a software project in collaboration with the undergraduate
students from the Department of Industrial Engineering (ISE) who is taking ISE 402 System Design
course.
You are required to work as a group of 6 CSE students and work collaboratively with a group from
ISE402. While the goal of the CSE group is to define the problem, analyse the problem and specify the
requirements, design the system, and implement & test the system as designed, the goal of the ISE group
is to define and analyse the problem. So, the two groups are required to work together in defining the
problem to be focused in their project, and analysing the problem to better understand its parts and
requirements, documenting the problem and its solution using a well-understood format (i.e., UML and
acceptable document outline). Note that the problem focused needs to be confirmed by each group.
In this course, you are essentially expected to gain the theoretical and practical knowledge of analyzing,
specifying, and designing a software system before starting with the implementation (coding). So, each
CSE team is supposed to prepare and submit (as a group) an analysis report first then develop a prototype
tool that satisfies the requirements. Note here that the analysis report is to be prepared together with the
ISE group and each statement given in the analysis report must be agreed by both group members. After
submitting the analysis report and demonstrating your prototype tool, you are expected to submit a
design report during the term. The report submissions need to be made as a softcopy (via YULEARN).
Note also that each CSE team is expected to implement your software system in the way you specified
and designed.
1- Analysis report (Deadline: March 21st, 2026)
It comprises the requirements specification, which is the first stage of developing a software system.
The requirements specification can be considered as the agreement between you and your customer. In
the requirement specification, each CSE team is expected to describe your software system that is
intended to solve the customer’s problem. It basically includes the functionality of the system (i.e., what
the software does and does not), the system’s interaction with the users, quality requirements, and design
constraints.
1. Introduction
1. Purpose – describe in short what this document serves for
2. Background – give information about the domain
3. Motivation
1. Statement of problems with the existing system
2. The new system – describe here the features of your new system by showing how they
solve the problems
4. Structure of the document
2. Project Planning and Process Management
1. Project Scope Overview
2. Work Breakdown Structure (WBS)
3. Gantt Chart
2
o Major tasks and milestones
o Task dependencies
o Timeline (weeks)
4. Task Allocation
o Team member responsibilities
o Role distribution
3. Functional Requirements
1. Description of the system functionalities
2. Description of the system users
3. Specific Requirements
1. Use Case Diagram
2. Use Case Priority List (with justification)
3. Use Case Specifications
4. Requirements Modeling
Students must construct a SysML Requirement Diagram to model relationships among
requirements.
The model must:
• Include all identified requirements
• Show hierarchical structure
• Show dependency and derived relationships
• Identify at least 3 cross-cutting or critical requirements
The diagram must clearly differ from the Use Case Diagram by focusing on requirement-torequirement
relationships, not actor-system interactions.
5. Non-Functional Requirements
1. Volere Template
6. System Models
1. UML Class Diagram for Domain Analysis
2. User Interface – navigational paths and screen mock-ups
7. Definitions, Acronyms and Abbreviations
8. Glossary & References
2- Prototype Software Tool Development (Deadline: April 18th, 2026)
This is the second stage where you are expected to develop a prototype software that includes the
graphical user interfaces regarding all the functional requirements and can be executed successfully.
The prototype software tool is expected to support all the user interfaces agreed with the ISE group.
Note that the prototype tool does not have to include the business logic (i.e., the implementation of the
functional requirements) and should rather focus on the user-interface aspect of the system. The business
logic is expected to be implemented in accordance with the software design.
Each prototype tool will be demonstrated to the course TA (To be announced) during the date and time
interval to be announced and you will get your grade.
3- Software design (Deadline: May 23rd, 2026)
This is the third stage in software development, which follows the requirements specification. In the
software design report, each CSE team is expected to describe the structure of your software system that
meets the requirements specified in the analysis report. The design report must clearly describe the
3
components of your software system and their relationships. You must also describe all necessary
information about these components so that programmers can use your design to implement the software
system.
A good structure for a design report can be as follows:
1. Introduction
1. Purpose of the document – what is this document for?
2. Purpose of the system – what is your proposed system for?
1. Describe your proposed system in terms of its users and the features provided to the
users.
3. Structure of the document
2. Systems Architecture Models
2.1 Context Diagram
Students must draw a Context Diagram showing:
• External stakeholders
• Internal stakeholders
• External systems
• System boundary and interactions
Flexible notation is allowed.
2.2 Logical Architecture – Package Diagram
Students must use a UML Package Diagram to represent:
• Logical units of the system
• Sub-units and modular decomposition
• High-level structural organization
2.3 Component Architecture (Mandatory)
For each major package, students must provide:
• A UML Component Diagram
• Clearly defined components
• Provided and required interfaces
• Connectors between components
The architecture must:
• Follow a clearly stated architectural style (e.g., Layered, Client-Server, Microservices, etc.)
• Be consistent with the chosen style
• Be traceable to the Package Diagram
Component-to-package mapping must be clearly visible.
3. Behavioral Modeling (Linked to Component Architecture)
Dynamic models must directly reflect the component architecture.
3.1 Sequence Diagrams
• For every interaction between two components in a Component Diagram, a corresponding
UML Sequence Diagram must be provided.
• The sequence diagram must clearly show how components communicate via their interfaces.
3.2 State Diagrams
• Each major component must have a UML State Diagram.
• The diagram must represent lifecycle states and transitions of that component.
3.3 Activity Diagrams
• For each Component Diagram (i.e., each logical unit), one UML Activity Diagram must be
provided.
• The activity diagram must show how components collaborate at a workflow level.
All behavioral diagrams must be consistent with:
• Component structure
• Interfaces
• Use cases
4
Inconsistency between structural and behavioral models will result in grade reduction.
4. Deployment Diagram
Students must provide a UML Deployment Diagram showing:
• Physical nodes
• Execution environments
• Mapping of components to physical devices
5. Detailed Design Class Diagram
1. Detailed class diagram for each major component
2. Attributes and methods
3. Associations, compositions, aggregations, multiplicities
Class design must be consistent with the component architecture.
6. Entity Relationship Diagram
(If persistent data is used)
7. Glossary & References
4- Software implementation (Deadline: 26th May, 2026)
This is the fourth stage in which each CSE team is supposed to implement the computer game you have
designed in the previous stage. You can use any object-oriented programming languages to implement
your system, e.g., Java, C++, and C#. The implementation code for each CSE team is to be submitted
online via YULEARN.
You should keep reports of every phase of your project. You should track your team members and assign
work via Trello (trello.com online collaboration tool). Your project development phases should follow
your initial project plan (Gantt chart) and if you have diverted from your initial time line, you should
justify it in your project’s final implementation report.
5- Project Process Management and Documentation (Deadline: 26th May,
2026)
This is the final stage in which each CSE team is supposed to ensure continuous progress and
structured teamwork throughout the semester. Each team is required to manage their project using
Trello (or an equivalent Kanban-based tool approved by the instructor).
1. Trello Usage
Each team must:
• Create a project board
• Define tasks as cards
• Assign responsibilities to team members
• Organize tasks under logical phases (e.g., Analysis, Design, Implementation)
• Track progress regularly
• Maintain visible activity history
The Trello board link must be submitted together with the final report.
Boards that show unrealistic last-minute activity or insufficient task breakdown may result in grade
reduction.
5
2. Weekly Meeting Minutes Report
Each team must submit a Meeting Minutes Report at the end of the semester.
For each week, the report must include:
• Meeting date
• Participants
• Agenda
• Key discussion points
• Decisions taken
• Assigned action items
• A photo (or screenshot for online meetings) taken during the meeting
The purpose of this requirement is to document the evolution of architectural and design decisions.
Failure to provide consistent weekly documentation may negatively affect the final grade.