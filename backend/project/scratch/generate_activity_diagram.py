import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom

# Define nodes for the Room Booking Flow Activity Diagram
nodes = [
    # Start node
    {
        "id": "start",
        "value": "",
        "style": "ellipse;whiteSpace=wrap;html=1;aspect=fixed;fillColor=#2a2a2a;strokeColor=#ffffff;",
        "x": 380, "y": 40, "w": 40, "h": 40
    },
    # Search
    {
        "id": "search",
        "value": "Search & Filter Rooms",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;",
        "x": 330, "y": 120, "w": 140, "h": 50
    },
    # Select
    {
        "id": "select",
        "value": "Select Room & View Details",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;",
        "x": 330, "y": 210, "w": 140, "h": 50
    },
    # Submit Request
    {
        "id": "submit",
        "value": "Submit Booking Request",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;",
        "x": 330, "y": 300, "w": 140, "h": 50
    },
    # Landlord Decision
    {
        "id": "decide",
        "value": "Landlord approves?",
        "style": "rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;align=center;",
        "x": 350, "y": 390, "w": 100, "h": 100
    },
    # Rejection Branch
    {
        "id": "reject_notify",
        "value": "Notify Tenant of Rejection",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#f8cecc;strokeColor=#b85450;fontStyle=1;",
        "x": 160, "y": 415, "w": 130, "h": 50
    },
    {
        "id": "end_reject",
        "value": "",
        "style": "ellipse;html=1;shape=endState;fillColor=#2a2a2a;strokeColor=#ffffff;",
        "x": 60, "y": 420, "w": 40, "h": 40
    },
    # Approval Branch
    {
        "id": "approve_status",
        "value": "Update Status to Approved",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;",
        "x": 330, "y": 530, "w": 140, "h": 50
    },
    {
        "id": "notify_tenant_pay",
        "value": "Notify Tenant & Request Payment",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;",
        "x": 330, "y": 620, "w": 140, "h": 50
    },
    {
        "id": "pay",
        "value": "Make Payment (Khalti/eSewa)",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#dae8fc;strokeColor=#6c8ebf;fontStyle=1;",
        "x": 330, "y": 710, "w": 140, "h": 50
    },
    # Payment Decision
    {
        "id": "pay_decide",
        "value": "Payment success?",
        "style": "rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;fontStyle=1;align=center;",
        "x": 350, "y": 800, "w": 100, "h": 100
    },
    # Payment Rejection
    {
        "id": "pay_fail_notify",
        "value": "Show Failure Alert & Notify",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#f8cecc;strokeColor=#b85450;fontStyle=1;",
        "x": 160, "y": 825, "w": 130, "h": 50
    },
    {
        "id": "end_pay_fail",
        "value": "",
        "style": "ellipse;html=1;shape=endState;fillColor=#2a2a2a;strokeColor=#ffffff;",
        "x": 60, "y": 830, "w": 40, "h": 40
    },
    # Payment Success
    {
        "id": "generate_agreement",
        "value": "Generate Digital Rental Agreement",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#e1d5e7;strokeColor=#9673a6;fontStyle=1;",
        "x": 330, "y": 940, "w": 140, "h": 50
    },
    {
        "id": "sign_agreement",
        "value": "Landlord & Tenant Sign digitally",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#e1d5e7;strokeColor=#9673a6;fontStyle=1;",
        "x": 330, "y": 1030, "w": 140, "h": 50
    },
    {
        "id": "reserve_room",
        "value": "Activate Booking & Block Room availability",
        "style": "rounded=1;whiteSpace=wrap;html=1;arcSize=30;fillColor=#d5e8d4;strokeColor=#82b366;fontStyle=1;",
        "x": 330, "y": 1120, "w": 140, "h": 50
    },
    {
        "id": "end_success",
        "value": "",
        "style": "ellipse;html=1;shape=endState;fillColor=#2a2a2a;strokeColor=#ffffff;",
        "x": 380, "y": 1210, "w": 40, "h": 40
    }
]

# Define control flows (edges) with optional decisions
edges = [
    {"id": "e1", "source": "start", "target": "search", "label": ""},
    {"id": "e2", "source": "search", "target": "select", "label": ""},
    {"id": "e3", "source": "select", "target": "submit", "label": ""},
    {"id": "e4", "source": "submit", "target": "decide", "label": ""},
    
    # Rejection branch
    {"id": "e5", "source": "decide", "target": "reject_notify", "label": "Rejected", "style": "exitX=0;exitY=0.5;entryX=1;entryY=0.5;"},
    {"id": "e6", "source": "reject_notify", "target": "end_reject", "label": ""},
    
    # Approval branch
    {"id": "e7", "source": "decide", "target": "approve_status", "label": "Approved", "style": "exitX=0.5;exitY=1;entryX=0.5;entryY=0;"},
    {"id": "e8", "source": "approve_status", "target": "notify_tenant_pay", "label": ""},
    {"id": "e9", "source": "notify_tenant_pay", "target": "pay", "label": ""},
    {"id": "e10", "source": "pay", "target": "pay_decide", "label": ""},
    
    # Payment Rejection
    {"id": "e11", "source": "pay_decide", "target": "pay_fail_notify", "label": "No", "style": "exitX=0;exitY=0.5;entryX=1;entryY=0.5;"},
    {"id": "e12", "source": "pay_fail_notify", "target": "end_pay_fail", "label": ""},
    
    # Payment Success
    {"id": "e13", "source": "pay_decide", "target": "generate_agreement", "label": "Yes", "style": "exitX=0.5;exitY=1;entryX=0.5;entryY=0;"},
    {"id": "e14", "source": "generate_agreement", "target": "sign_agreement", "label": ""},
    {"id": "e15", "source": "sign_agreement", "target": "reserve_room", "label": ""},
    {"id": "e16", "source": "reserve_room", "target": "end_success", "label": ""}
]

# Build XML tree
mxfile = ET.Element("mxfile", host="app.diagrams.net")
diagram = ET.SubElement(mxfile, "diagram", name="Room Booking Activity Flow", id="page-2")

mxGraphModel = ET.SubElement(
    diagram, 
    "mxGraphModel", 
    dx="1422", 
    dy="762", 
    grid="1", 
    gridSize="10", 
    guides="1", 
    tooltips="1", 
    connect="1", 
    arrows="1", 
    fold="1", 
    page="1", 
    pageScale="1", 
    pageWidth="827", 
    pageHeight="1169", 
    math="0", 
    shadow="0"
)

root = ET.SubElement(mxGraphModel, "root")

# Core base nodes
ET.SubElement(root, "mxCell", id="0")
ET.SubElement(root, "mxCell", id="1", parent="0")

# Render action / decision nodes
for n in nodes:
    cell = ET.SubElement(root, "mxCell", id=n["id"], value=n["value"], style=n["style"], vertex="1", parent="1")
    ET.SubElement(cell, "mxGeometry", x=str(n["x"]), y=str(n["y"]), width=str(n["w"]), height=str(n["h"]), attrib={"as": "geometry"})

# Render edges
for e in edges:
    style = e.get("style", "endArrow=block;endFill=1;html=1;edgeStyle=orthogonalEdgeStyle;rounded=0;")
    edge_cell = ET.SubElement(root, "mxCell", id=e["id"], style=style, edge="1", source=e["source"], target=e["target"], parent="1")
    ET.SubElement(edge_cell, "mxGeometry", relative="1", attrib={"as": "geometry"})
    
    # If the edge has a label, add it as a child mxCell
    if e["label"]:
        label_cell = ET.SubElement(
            root, 
            "mxCell", 
            id=f"{e['id']}_label", 
            value=e["label"], 
            style="edgeLabel;html=1;align=center;verticalAlign=middle;resizable=0;points=[];fontStyle=1;fontSize=11;", 
            vertex="1", 
            connectable="0", 
            parent=e["id"]
        )
        ET.SubElement(label_cell, "mxGeometry", x="-0.1", relative="1", attrib={"as": "geometry"})

# Write XML and format
raw_xml = ET.tostring(mxfile, encoding="utf-8")
reparsed = minidom.parseString(raw_xml)
pretty_xml = reparsed.toprettyxml(indent="  ")

# Strip XML header
if pretty_xml.startswith("<?xml"):
    pretty_xml = pretty_xml.split("\n", 1)[1]

# Save file
with open("c:/Users/ayush/OneDrive/Desktop/7th sem project/diagram/booking_activity_diagram.drawio", "w", encoding="utf-8") as f:
    f.write(pretty_xml)

print("Activity diagram XML generated successfully!")
