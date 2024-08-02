import pathlib
import sys

import ifcopenshell
from ifcopenshell.api import run
import ifcopenshell.api.project
import ifcopenshell.validate
import ifcopenshell.guid
import subprocess
import random
import hashlib
import uuid
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def test_basic_boxes():
    fname = pathlib.Path("temp/basic_boxes.ifc")
    create_boxes_ifc(fname)

    if sys.platform == "win32":
        convert_exe = "IfcConvert.exe"
    else:
        convert_exe = "IfcConvert"

    r = subprocess.run([convert_exe, str(fname), str(fname.with_suffix(".glb"))])
    assert r.returncode == 0
    print(r)


def create_boxes_ifc(fname):
    from pprint import pprint
    # Create a grid of IFC boxes
    #
    # This is a simple example of how to create a grid of IFC boxes.

    # Create a new IFC file
    f = ifcopenshell.api.project.create_file(version="IFC4X3")

    # Create a new IFC building storey
    storey = basic_project_and_storey(f)

    # loop over a x,y,z grid of range=NUM_GRID of boxes and add them under the storey
    boxes = []
    max_size = 0.8
    min_size = 0.5
    NUM_GRID = 3
    for x in range(NUM_GRID):
        for y in range(NUM_GRID):
            for z in range(NUM_GRID):
                box = create_ifc_box(f, f"bob{x}{y}{z}", (x, y, z), random.uniform(min_size, max_size),
                                     random.uniform(min_size, max_size), random.uniform(min_size, max_size))
                boxes.append(box)

    f.createIfcRelContainedInSpatialStructure(GlobalId=create_guid(),
                                              Name="Physical model",
                                              Description=None,
                                              RelatedElements=boxes,
                                              RelatingStructure=storey)
    logger = ifcopenshell.validate.json_logger()
    f.write(fname)
    ifcopenshell.validate.validate(fname, logger, express_rules=True)

    pprint(logger.statements)


def create_guid(name=None):
    """Creates a guid from a random name or bytes or generates a random guid"""

    if name is None:
        hexdig = uuid.uuid1().hex
    else:
        if type(name) != bytes:
            n = name.encode()
        else:
            n = name
        hexdig = hashlib.md5(n).hexdigest()
    result = ifcopenshell.guid.compress(hexdig)
    return result


def get_context(f, context_id):
    contexts = list(f.by_type("IfcGeometricRepresentationContext"))
    subcontexts = list(f.by_type("IfcGeometricRepresentationSubContext"))
    if len(contexts) == 1 and len(subcontexts) == 0:
        return contexts[0]

    contexts = [x for x in contexts if x.ContextIdentifier == context_id and x.ContextType == "Model"]
    if len(contexts) == 0:
        raise ValueError(f'0 IfcGeometry Subcontexts found with "{context_id=}"')
    if len(contexts) > 1:
        raise ValueError(f'Multiple Subcontexts found with "{context_id=}"')

    return contexts[0]


def create_ifc_box(f: ifcopenshell.file, name, origin, height, width, length) -> ifcopenshell.entity_instance:
    origin = f.createIfcCartesianPoint([float(x) for x in origin])
    axis3d = f.createIfcAxis2Placement3D(origin, None, None)
    solid_geom = f.createIfcBlock(Position=axis3d, XLength=width, YLength=length, ZLength=height)
    body_context = get_context(f, "Body")
    shape_representation = f.create_entity("IfcShapeRepresentation", ContextOfItems=body_context,
                                           RepresentationIdentifier="Body", RepresentationType="SweptSolid",
                                           Items=[solid_geom])
    prod_def = f.create_entity("IfcProductDefinitionShape", Representations=[shape_representation])
    box = f.create_entity("IfcBuildingElementProxy", GlobalId=create_guid(), Name=name, Representation=prod_def)
    return box


def basic_project_and_storey(model: ifcopenshell.file) -> ifcopenshell.entity_instance:
    # All projects must have one IFC Project element
    project = run("root.create_entity", model, ifc_class="IfcProject", name="My Project")

    # Geometry is optional in IFC, but because we want to use geometry in this example, let's define units
    run("unit.assign_unit", model, **{"length": {"is_metric": True, "raw": "METERS"}})

    # Let's create a modeling geometry context, so we can store 3D geometry (note: IFC supports 2D too!)
    context = run("context.add_context", model, context_type="Model")

    # In particular, in this example we want to store the 3D "body" geometry of objects, i.e. the body shape
    run("context.add_context", model, context_type="Model",
        context_identifier="Body", target_view="MODEL_VIEW", parent=context)

    # Create a site, building, and storey. Many hierarchies are possible.
    site = run("root.create_entity", model, ifc_class="IfcSite", name="My Site")
    building = run("root.create_entity", model, ifc_class="IfcBuilding", name="Building A")
    storey = run("root.create_entity", model, ifc_class="IfcBuildingStorey", name="Ground Floor")

    # Since the site is our top level location, assign it to the project
    # Then place our building on the site, and our storey in the building
    run("aggregate.assign_object", model, relating_object=project, products=[site])
    run("aggregate.assign_object", model, relating_object=site, products=[building])
    run("aggregate.assign_object", model, relating_object=building, products=[storey])

    return storey
