// @preview-file on
import {ArrayEvent, StructEvent, Struct, StructArray} from 'Utils';

// create struct definitions
interface ActionStruct {
	name: string;
	id: string;
};
interface UnitStruct {
	name: string;
	group: number;
	tag: string;
	actions: StructArray<ActionStruct>;
};
const Unit = Struct.My.Name.Space.Unit<UnitStruct>("name", "group", "tag", "actions");
const Action = Struct.Action<ActionStruct>("name", "id");
const Array = Struct.Array<ActionStruct>();

// create instance
const unit = Unit({
	name: "abc",
	group: 123,
	tag: "tagX",
	actions: Array([
		Action({name: "walk", id: "a1"}),
		Action({name: "run", id: "a2"}),
		Action({name: "sleep", id: "a3"})
	])
});

// get notified when record field changes
unit.__notify = (event, key, value) => {
	switch (event) {
		case StructEvent.Modified:
			print(`Value of name \"${key}\" changed to ${value}.`);
			break;
		case StructEvent.Updated:
			print("Values updated.");
			break;
	}
};

// get notified when list item changes
unit.actions.__notify = (event, index, item) => {
	switch (event) {
		case ArrayEvent.Added:
			print(`Add item ${item} at index ${index}.`);
			break;
		case ArrayEvent.Removed:
			print(`Remove item ${item} at index ${index}.`);
			break;
		case ArrayEvent.Changed:
			print(`Change item to ${item} at index ${index}.`);
			break;
		case ArrayEvent.Updated:
			print("Items updated.");
			break;
	}
};

unit.name = "pig";
unit.actions.insert(Action({name: "idle", id: "a4"}));
unit.actions.removeAt(1);

const structStr = tostring(unit);
print(structStr);

const loadedUnit = Struct.load(structStr) as Struct<UnitStruct>;
for (let i = 1; i <= loadedUnit.actions.count(); i++) {
	print(i, loadedUnit.actions.get(i));
}

print(Struct);

// clear all the Struct definitions
Struct.clear();
