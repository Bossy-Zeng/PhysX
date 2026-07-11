// PhysX C API Wrapper for P/Invoke from C#
// This file provides C-linkage wrappers around key PhysX C++ functions

#include "PxPhysicsAPI.h"

extern "C"
{

    // Store pointers as opaque handles
    static physx::PxFoundation *g_Foundation = nullptr;
    static physx::PxPhysics *g_Physics = nullptr;
    static physx::PxDefaultAllocator g_Allocator;
    static physx::PxDefaultErrorCallback g_ErrorCallback;

    // Initialize PhysX foundation and physics
    int PhysX_Initialize()
    {
        g_Foundation = PxCreateFoundation(PX_PHYSICS_VERSION, g_Allocator, g_ErrorCallback);
        if (!g_Foundation)
            return -1;

        g_Physics = PxCreatePhysics(PX_PHYSICS_VERSION, *g_Foundation, physx::PxTolerancesScale());
        if (!g_Physics)
            return -2;

        return 0;
    }

    // Shutdown PhysX
    void PhysX_Shutdown()
    {
        if (g_Physics)
        {
            g_Physics->release();
            g_Physics = nullptr;
        }
        if (g_Foundation)
        {
            g_Foundation->release();
            g_Foundation = nullptr;
        }
    }

    // Check if PhysX is initialized
    int PhysX_IsInitialized()
    {
        return (g_Physics != nullptr) ? 1 : 0;
    }

    // Get PhysX version
    int PhysX_GetVersion()
    {
        return PX_PHYSICS_VERSION;
    }

    // Simulate a box dropping from height 10 onto a plane, return Y position
    float PhysX_SimulateBoxDrop(int numSteps)
    {
        if (!g_Physics)
            return -999.0f;

        physx::PxSceneDesc sceneDesc(g_Physics->getTolerancesScale());
        sceneDesc.gravity = physx::PxVec3(0.0f, -9.81f, 0.0f);
        sceneDesc.cpuDispatcher = physx::PxDefaultCpuDispatcherCreate(1);
        sceneDesc.filterShader = physx::PxDefaultSimulationFilterShader;

        physx::PxScene *scene = g_Physics->createScene(sceneDesc);
        if (!scene)
            return -998.0f;

        // Ground plane
        physx::PxMaterial *groundMaterial = g_Physics->createMaterial(0.5f, 0.5f, 0.1f);
        physx::PxRigidStatic *groundPlane = physx::PxCreatePlane(
            *g_Physics, physx::PxPlane(0, 1, 0, 0), *groundMaterial);
        scene->addActor(*groundPlane);

        // Dynamic box at height 10
        physx::PxMaterial *material = g_Physics->createMaterial(0.5f, 0.5f, 0.1f);
        physx::PxTransform transform(physx::PxVec3(0.0f, 10.0f, 0.0f));
        physx::PxBoxGeometry geometry(physx::PxVec3(0.5f, 0.5f, 0.5f));
        physx::PxRigidDynamic *box = physx::PxCreateDynamic(*g_Physics, transform, geometry, *material, 1.0f);
        scene->addActor(*box);

        // Simulate
        float dt = 1.0f / 60.0f;
        for (int i = 0; i < numSteps; i++)
        {
            scene->simulate(dt);
            scene->fetchResults(true);
        }

        float y = box->getGlobalPose().p.y;
        scene->release();
        return y;
    }

    int PhysX_GetVersionMajor() { return PX_PHYSICS_VERSION_MAJOR; }
    int PhysX_GetVersionMinor() { return PX_PHYSICS_VERSION_MINOR; }
    int PhysX_GetVersionPatch() { return PX_PHYSICS_VERSION_BUGFIX; }

} // extern "C"