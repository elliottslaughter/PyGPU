#include <data_type.h>
#include <cuda_hip_wrapper.h>
#include <pybind11/pybind11.h>


namespace py = pybind11;


PYBIND11_MODULE(backend, m) {

    // Build all enumerations used internally by cuda bindings
    generate_enumeration(m);

    // Build all datatype wrapper bindings
    generate_datatype(m);

    py::class_<CudaError>(m, "cudaError_t")
        .def(py::init<int>())
        .def("as_int", & CudaError::as_int)
        .def("__repr__",
            [](const CudaError & a) {
                return "<CudaError: 'code=" + std::to_string(a.as_int()) + "'>";
            }
        );

    // py::class_<obj_wrapper<cudaEvent_t>>(m, "cudaError_t")
    //    .def(py::init<int>())
 

    // TODO: this is a clumsy way to define data types -- clean this up a wee
    // bit in the future.

    py::class_<ptr_wrapper<cudaEvent_t>>(m, "cudaEvent_t");

    m.def(
        "NewCudaEvent_t",
        []() {return ptr_wrapper<cudaEvent_t>(new cudaEvent_t); }
    );

    py::class_<ptr_wrapper<cudaStream_t>>(m, "cudaStream_t");

    m.def(
        "NewCudaStream_t",
        []() {return ptr_wrapper<cudaStream_t>(new cudaStream_t); }
    );

    py::class_<ptr_wrapper<int *>>(m, "IntPtr_t");

    m.def(
        "NewIntPtr_t",
        []() {return ptr_wrapper<int *>(new int *); }
    );

    py::class_<ptr_wrapper<double *>>(m, "DoublePtr_t");

    m.def(
        "NewDoublePtr_t",
        []() {return ptr_wrapper<double *>(new double *); }
    );


    m.def(
        "cudaDeviceReset",
        []() {
            return CudaError(cudaDeviceReset());
        }
    );


    m.def(
        "cudaDeviceSynchronize",
        []() {
            return CudaError(cudaDeviceSynchronize());
        }
    );


    m.def(
        "cudaEventCreate",
        [](ptr_wrapper<cudaEvent_t> event, unsigned int flags) {
            return CudaError(cudaEventCreate(event.get(), flags));
        }
    );


    m.def(
        "cudaEventElapsedTime",
        [](
            ptr_wrapper<float> ms,
            ptr_wrapper<cudaEvent_t> start,
            ptr_wrapper<cudaEvent_t> end
        ) {
            return CudaError(cudaEventElapsedTime(ms.get(), * start, * end));
        }
    );


    m.def(
        "cudaEventRecord",
        [](
            ptr_wrapper<cudaEvent_t> event,
            ptr_wrapper<cudaStream_t> end = 0
        ) {
            return CudaError(cudaEventRecord(* event, * end));
        }
    );


    m.def(
        "cudaEventSynchronize",
        [](ptr_wrapper<cudaEvent_t> event) {
            return CudaError(cudaEventSynchronize(* event));
        }
    );


    m.def(
        "cudaFree",
        [](void * dev_ptr) {
            return CudaError(cudaFree(dev_ptr));
        }
    );


    m.def(
        "cudaFreeHost",
        [](void * ptr) {
            return CudaError(cudaFreeHost(ptr));
        }
    );


    m.def(
        "cudaGetDevice",
        [](ptr_wrapper<int> device) {
            return CudaError(cudaGetDevice(device.get()));
        }
    );


    m.def(
        "cudaGetErrorName",
        [](ptr_wrapper<cudaError_t> error) {
            return std::string(cudaGetErrorName(* error));
        }
    );


    m.def(
        "cudaGetErrorString",
        [](ptr_wrapper<cudaError_t> error) {
            return std::string(cudaGetErrorString(* error));
        }
    );


    m.def(
        "cudaGetLastError",
        []() {
            return CudaError(cudaGetLastError());
        }
    );


    // TODO: Template the argument data type
    m.def(
        "cudaMalloc",
        [](ptr_wrapper<int *> dev_ptr, uint64_t size) {
            return CudaError(cudaMalloc(dev_ptr.get(), size*sizeof(int)));
        }
    );

    m.def(
        "cudaMalloc",
        [](ptr_wrapper<double *> dev_ptr, uint64_t size) {
            return CudaError(cudaMalloc(dev_ptr.get(), size*sizeof(double)));
        }
    );


    // TODO: Template the argument data type
    m.def(
        "cudaMallocHost",
        [](ptr_wrapper<int *> dev_ptr, uint64_t size) {
            return CudaError(cudaMallocHost(dev_ptr.get(), size*sizeof(int)));
        }
    );

    m.def(
        "cudaMallocHost",
        [](ptr_wrapper<double *> dev_ptr, uint64_t size) {
            // TODO: use custom type for cudaError_t
            return CudaError(cudaMallocHost(dev_ptr.get(), size*sizeof(double)));
        }
    );

// //  __host__ ​cudaError_t cudaMemcpy ( void* dst, const void* src, size_t count, cudaMemcpyKind kind ) 
// cudaMemcpyDeviceToHost
// cudaMemcpyHostToDevice
// 
//     // TODO: Template the argument data type to direct data
//     // using custom argument type
//     m.def(
//         "cudaMemcpyDeviceToHost",
//         [](ptr_wrapper<int> dst, ptr_wrapper<int> src, uint64_t count) {
//             // TODO: use custom type for cudaError_t
//             return (int64_t) cudaMemcpy();
//         }
//     );
// 
//     m.def(
//         "cudaMallocHost",
//         [](ptr_wrapper<double *> dev_ptr, uint64_t size) {
//             // TODO: use custom type for cudaError_t
//             return (int64_t) cudaMallocHost(dev_ptr.get(), size*sizeof(double));
//         }
//     );




    m.attr("major_version")   = py::int_(0);
    m.attr("minor_version")   = py::int_(1);
    m.attr("release_version") = py::int_(0);

    // Let the user know that this backend has been compiled _with_ CUDA support
    m.attr("cuda_enabled")            = py::bool_(true);
}
