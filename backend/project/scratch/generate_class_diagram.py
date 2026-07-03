import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom

# Define classes and their structure
classes = [
    {
        "id": "100",
        "name": "CustomUser",
        "color": "#dae8fc",
        "stroke": "#6c8ebf",
        "x": 50, "y": 50, "w": 250,
        "attributes": [
            "+ id: UUID {PK}",
            "+ username: String",
            "+ email: String",
            "+ role: Role (tenant | landlord | admin)",
            "+ province: String",
            "+ district: String",
            "+ city: String",
            "+ ward: PositiveInteger",
            "+ fcm_token: String",
            "+ profile_picture: Image"
        ],
        "methods": []
    },
    {
        "id": "101",
        "name": "OTP",
        "color": "#dae8fc",
        "stroke": "#6c8ebf",
        "x": 380, "y": 50, "w": 220,
        "attributes": [
            "+ id: Integer {PK}",
            "- user_id: UUID {FK}",
            "+ code: String",
            "+ created_at: DateTime",
            "+ expires_at: DateTime",
            "+ is_used: Boolean"
        ],
        "methods": [
            "+ is_expired(): Boolean"
        ]
    },
    {
        "id": "102",
        "name": "Notification",
        "color": "#f8cecc",
        "stroke": "#b85450",
        "x": 680, "y": 50, "w": 220,
        "attributes": [
            "+ id: Integer {PK}",
            "- user_id: UUID {FK}",
            "+ content: Text",
            "+ is_read: Boolean",
            "+ created_at: DateTime"
        ],
        "methods": []
    },
    {
        "id": "103",
        "name": "Room",
        "color": "#d5e8d4",
        "stroke": "#82b366",
        "x": 50, "y": 420, "w": 260,
        "attributes": [
            "+ id: Integer {PK}",
            "- landlord_id: UUID {FK}",
            "+ title: String",
            "+ description: Text",
            "+ price: Decimal",
            "+ province: String",
            "+ state: String",
            "+ ward_number: PositiveInteger",
            "+ furnished_status: Boolean",
            "+ area_sqft: PositiveInteger",
            "+ security_deposit: Decimal",
            "+ maintenance_charges: Decimal",
            "+ has_wifi: Boolean",
            "+ has_ac: Boolean",
            "+ has_attached_bathroom: Boolean",
            "+ parking_available: Boolean",
            "+ food_available: Boolean",
            "+ gender_preference: String",
            "+ water_supply_available: Boolean",
            "+ waste_collection_available: Boolean",
            "+ is_available: Boolean",
            "+ latitude: Decimal",
            "+ longitude: Decimal",
            "+ created_at: DateTime",
            "+ updated_at: DateTime"
        ],
        "methods": [
            "+ __str__(): String"
        ]
    },
    {
        "id": "104",
        "name": "RoomImage",
        "color": "#d5e8d4",
        "stroke": "#82b366",
        "x": 380, "y": 420, "w": 220,
        "attributes": [
            "+ id: Integer {PK}",
            "- room_id: Integer {FK}",
            "+ image: Image",
            "+ created_at: DateTime"
        ],
        "methods": [
            "+ __str__(): String"
        ]
    },
    {
        "id": "105",
        "name": "MaintenanceRequest",
        "color": "#f8cecc",
        "stroke": "#b85450",
        "x": 680, "y": 420, "w": 240,
        "attributes": [
            "+ id: Integer {PK}",
            "- tenant_id: UUID {FK}",
            "- room_id: Integer {FK}",
            "+ description: Text",
            "+ status: Status",
            "+ image: Image",
            "+ created_at: DateTime"
        ],
        "methods": [
            "+ __str__(): String"
        ]
    },
    {
        "id": "106",
        "name": "Booking",
        "color": "#fff2cc",
        "stroke": "#d6b656",
        "x": 50, "y": 1200, "w": 250,
        "attributes": [
            "+ id: Integer {PK}",
            "- tenant_id: UUID {FK}",
            "- room_id: Integer {FK}",
            "+ status: Status",
            "+ created_at: DateTime"
        ],
        "methods": [
            "+ __str__(): String"
        ]
    },
    {
        "id": "107",
        "name": "Agreement",
        "color": "#e1d5e7",
        "stroke": "#9673a6",
        "x": 380, "y": 1200, "w": 220,
        "attributes": [
            "+ id: Integer {PK}",
            "- booking_id: Integer {FK, O2O}",
            "+ content: Text",
            "+ is_signed: Boolean",
            "+ created_at: DateTime",
            "+ signed_at: DateTime"
        ],
        "methods": []
    },
    {
        "id": "108",
        "name": "Payment",
        "color": "#f8cecc",
        "stroke": "#b85450",
        "x": 680, "y": 1200, "w": 240,
        "attributes": [
            "+ id: Integer {PK}",
            "- booking_id: Integer {FK}",
            "+ amount: Decimal",
            "+ status: Status",
            "+ payment_gateway: Gateway",
            "+ transaction_token: String",
            "+ gateway_response: JSON",
            "+ created_at: DateTime"
        ],
        "methods": [
            "+ __str__(): String"
        ]
    },
    {
        "id": "109",
        "name": "Message",
        "color": "#fff2cc",
        "stroke": "#d6b656",
        "x": 980, "y": 1200, "w": 220,
        "attributes": [
            "+ id: Integer {PK}",
            "- sender_id: UUID {FK}",
            "- receiver_id: UUID {FK}",
            "+ content: Text",
            "+ is_read: Boolean",
            "+ booking_id: Integer",
            "+ created_at: DateTime"
        ],
        "methods": []
    }
]

# Define associations (edges)
relationships = [
    # CustomUser -> OTP (1 to many, composition)
    {"id": "r100", "source": "100", "target": "101", "style": "endArrow=open;html=1;endSize=8;startArrow=diamondThin;startSize=14;startFill=1;edgeStyle=orthogonalEdgeStyle;exitX=1;exitY=0.25;entryX=0;entryY=0.25;"},
    # CustomUser -> Notification (1 to many, association)
    {"id": "r101", "source": "100", "target": "102", "style": "endArrow=open;html=1;endSize=8;startArrow=none;edgeStyle=orthogonalEdgeStyle;exitX=1;exitY=0.75;entryX=0;entryY=0.5;"},
    # CustomUser -> Room (1 to many, landlord)
    {"id": "r102", "source": "100", "target": "103", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=0.25;exitY=1;entryX=0.25;entryY=0;"},
    # Room -> RoomImage (1 to many, composition)
    {"id": "r103", "source": "103", "target": "104", "style": "endArrow=open;html=1;endSize=8;startArrow=diamondThin;startSize=14;startFill=1;edgeStyle=orthogonalEdgeStyle;exitX=1;exitY=0.1;entryX=0;entryY=0.25;"},
    # CustomUser -> MaintenanceRequest (1 to many, tenant)
    {"id": "r104", "source": "100", "target": "105", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=0.75;exitY=1;entryX=0.5;entryY=0;"},
    # Room -> MaintenanceRequest (1 to many)
    {"id": "r105", "source": "103", "target": "105", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=1;exitY=0.3;entryX=0;entryY=0.5;"},
    # Room -> Booking (1 to many)
    {"id": "r106", "source": "103", "target": "106", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=0.25;exitY=1;entryX=0.25;entryY=0;"},
    # CustomUser -> Booking (1 to many, tenant)
    {"id": "r107", "source": "100", "target": "106", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=0.05;exitY=1;entryX=0.05;entryY=0;"},
    # Booking -> Agreement (1 to 1)
    {"id": "r108", "source": "106", "target": "107", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=1;exitY=0.25;entryX=0;entryY=0.25;"},
    # Booking -> Payment (1 to many, composition)
    {"id": "r109", "source": "106", "target": "108", "style": "endArrow=open;html=1;endSize=8;startArrow=diamondThin;startSize=14;startFill=1;edgeStyle=orthogonalEdgeStyle;exitX=1;exitY=0.75;entryX=0;entryY=0.5;"},
    # CustomUser -> Message (sender/receiver)
    {"id": "r110", "source": "100", "target": "109", "style": "endArrow=open;html=1;endSize=8;edgeStyle=orthogonalEdgeStyle;exitX=0.9;exitY=1;entryX=0.5;entryY=0;"},
]

# Build the XML
mxfile = ET.Element("mxfile", host="app.diagrams.net")
diagram = ET.SubElement(mxfile, "diagram", name="Backend Class Diagram", id="page-1")

# Standard graph model details with viewport properties
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

# Base layers
ET.SubElement(root, "mxCell", id="0")
ET.SubElement(root, "mxCell", id="1", parent="0")

# Render each class
for c in classes:
    class_id = c["id"]
    class_name = c["name"]
    
    # Calculate auto height based on contents
    header_h = 26
    attrs_h = len(c["attributes"]) * 26
    div_h = 8 if c["methods"] else 0
    methods_h = len(c["methods"]) * 26
    total_height = header_h + attrs_h + div_h + methods_h
    
    # Class container
    container_style = (
        f"swimlane;fontStyle=1;align=center;verticalAlign=top;childLayout=stackLayout;"
        f"horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;"
        f"resizeLast=0;collapsible=1;marginBottom=0;html=1;fillColor={c['color']};strokeColor={c['stroke']};"
    )
    container_cell = ET.SubElement(root, "mxCell", id=class_id, value=class_name, style=container_style, vertex="1", parent="1")
    ET.SubElement(container_cell, "mxGeometry", x=str(c["x"]), y=str(c["y"]), width=str(c["w"]), height=str(total_height), attrib={"as": "geometry"})
    
    y_offset = header_h
    
    # Attributes
    for attr in c["attributes"]:
        attr_style = "text;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;portConstraint=eastwest;rotatable=0;points=[[0,0.5],[1,0.5]];html=1;"
        attr_cell = ET.SubElement(root, "mxCell", id=f"{class_id}_attr_{y_offset}", value=attr, style=attr_style, vertex="1", parent=class_id)
        ET.SubElement(attr_cell, "mxGeometry", x="0", y=str(y_offset), width=str(c["w"]), height="26", attrib={"as": "geometry"})
        y_offset += 26
        
    # Divider (if methods exist)
    if c["methods"]:
        div_style = "line;strokeWidth=1;fillColor=none;align=left;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;rotatable=0;points=[];html=1;"
        div_cell = ET.SubElement(root, "mxCell", id=f"{class_id}_div_{y_offset}", value="", style=div_style, vertex="1", parent=class_id)
        ET.SubElement(div_cell, "mxGeometry", x="0", y=str(y_offset), width=str(c["w"]), height="8", attrib={"as": "geometry"})
        y_offset += 8
        
    # Methods
    for method in c["methods"]:
        method_style = "text;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;portConstraint=eastwest;rotatable=0;points=[[0,0.5],[1,0.5]];html=1;"
        method_cell = ET.SubElement(root, "mxCell", id=f"{class_id}_meth_{y_offset}", value=method, style=method_style, vertex="1", parent=class_id)
        ET.SubElement(method_cell, "mxGeometry", x="0", y=str(y_offset), width=str(c["w"]), height="26", attrib={"as": "geometry"})
        y_offset += 26

# Render relationships
for r in relationships:
    edge_cell = ET.SubElement(root, "mxCell", id=r["id"], style=r["style"], edge="1", source=r["source"], target=r["target"], parent="1")
    ET.SubElement(edge_cell, "mxGeometry", relative="1", attrib={"as": "geometry"})

# Write to file
raw_xml = ET.tostring(mxfile, encoding="utf-8")
reparsed = minidom.parseString(raw_xml)
pretty_xml = reparsed.toprettyxml(indent="  ")

# Strip the <?xml ...?> line if present
if pretty_xml.startswith("<?xml"):
    pretty_xml = pretty_xml.split("\n", 1)[1]

# Save file
with open("c:/Users/ayush/OneDrive/Desktop/7th sem project/diagram/backend_class_diagram.drawio", "w", encoding="utf-8") as f:
    f.write(pretty_xml)

print("Class diagram XML generated successfully with standard attributes!")
