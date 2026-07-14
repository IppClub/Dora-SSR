-- Statistics captured from the most recent 3D render for a View3D.
local record RenderStats3D
	const sceneNodes: integer
	const visibleVisuals: integer
	const culledVisuals: integer
	const opaqueItems: integer
	const transparentItems: integer
	const drawCalls: integer
	const triangles: integer
	const programSwitches: integer
	const materialSwitches: integer
	const textureSwitches: integer
	const meshSwitches: integer
	const nodeCount: integer
	const visualCount: integer
	const modelCount: integer
	const modelInstanceCount: integer
	const meshCount: integer
	const staticMeshCount: integer
	const dynamicMeshCount: integer
	const materialCount: integer
	const textureCount: integer
	const animationCount: integer
	const environmentCount: integer
	const modelResidentBytes: integer
	const meshResidentBytes: integer
	const textureResidentBytes: integer
	const collectMicros: integer
	const sortMicros: integer
	const submitMicros: integer
	const uploadCommands: integer
	const uploadBytes: integer
	const uploadMicros: integer
	const uploadMaxCommandMicros: integer
end

return RenderStats3D
