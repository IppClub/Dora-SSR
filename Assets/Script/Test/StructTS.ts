// @preview-file on
import {ArrayEvent, RecordEvent, Struct, StructEvent} from 'Utils';

// create struct definitions
interface UnitStruct {
	name: string;
	group: number;
	tag: string;
	actions: Struct;
};
const Unit = Struct.My.Name.Space.Unit<UnitStruct>("name", "group", "tag", "actions");
interface ActionStruct {
	name: string;
	id: string;
};
const Action = Struct.Action<ActionStruct>("name", "id");
const Array = Struct.Array();

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
unit.__notify = (event: RecordEvent | StructEvent, key: string, value) => {
	switch (event) {
		case RecordEvent.Modified:
			print(`Value of name \"${key}\" changed to ${value}.`);
			break;
		case StructEvent.Updated:
			print("Values updated.");
			break;
	}
};

// get notified when list item changes
unit.actions.__notify = (event: ArrayEvent | StructEvent, index: number, item: any) => {
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
		case StructEvent.Updated:
			print("Items updated.");
			break;
	}
};

unit.name = "pig";
unit.actions.insert(Action({name: "idle", id: "a4"}));
unit.actions.removeAt(1);

const structStr = tostring(unit);
print(structStr);

const loadedUnit = Struct.load<UnitStruct>(structStr);
for (let i = 1; i <= loadedUnit.actions.count(); i++) {
	print(i, loadedUnit.actions.get(i));
}

print(Struct);

// clear all the Struct definitions
Struct.clear();
