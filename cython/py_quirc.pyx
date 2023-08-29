cdef extern from "../lib/quirc_api.h":
    cdef void init(int width, int height)
    cdef void decode(int img[], int width, int height, int *out)
    cdef void destroy(int dummy)

from cpython cimport array
import array
import numpy as np

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class QrDecodedData:
    def __init__(self, qr_information_array):
        ''' Args:
            Array of size 9 with the following information:
            0. QR_id: Data inside the QR
            1. corner0 X of QR
            2. corner0 Y of QR
            3. corner1 X of QR
            4. corner1 Y of QR
            5. corner2 X of QR
            6. corner2 Y of QR
            7. corner3 X of QR
            8. corner3 Y of QR
        '''
        p0 = Point(qr_information_array[1], qr_information_array[2])
        p1 = Point(qr_information_array[3], qr_information_array[4])
        p2 = Point(qr_information_array[5], qr_information_array[6])
        p3 = Point(qr_information_array[7], qr_information_array[8])
        polygon = [p0, p1, p2, p3]

        self.data = qr_information_array[0]
        self.center = self.__get_center(polygon)
        self.top_left = self.__get_top_left(polygon)
        self.top_right = self.__get_top_right(polygon)
        self.bottom_left = self.__get_bottom_left(polygon)
        self.bottom_right = self.__get_bottom_right(polygon)
        self.middle_top = self.__get_middle_top(polygon)
        self.middle_bottom = self.__get_middle_bottom(polygon)

    def __get_center(self, polygon):
        center_x = (polygon[0].x + polygon[1].x + polygon[2].x + polygon[3].x) // 4   
        center_y = (polygon[0].y + polygon[1].y + polygon[2].y + polygon[3].y) // 4   
        return [center_x, center_y]

    def __get_middle_top(self, polygon):
        top_left = self.__get_top_left(polygon)
        top_right = self.__get_top_right(polygon)
        middle_x = (top_left[0] + top_right[0]) // 2
        middle_y = (top_left[1] + top_right[1]) // 2
        return [middle_x, middle_y]

    def __get_middle_bottom(self, polygon):
        bottom_left = self.__get_bottom_left(polygon)
        bottom_right = self.__get_bottom_right(polygon)
        middle_x = (bottom_left[0] + bottom_right[0]) // 2
        middle_y = (bottom_left[1] + bottom_right[1]) // 2
        return [middle_x, middle_y]

    def __get_top_left(self, polygon):
        return min(self.__get_tops(polygon))

    def __get_top_right(self, polygon):
        return max(self.__get_tops(polygon))

    def __get_bottom_left(self, polygon):
        return min(self.__get_bottoms(polygon))

    def __get_bottom_right(self, polygon):
        return max(self.__get_bottoms(polygon))

    def __get_tops(self, polygon):
        return sorted(polygon, key=lambda p: p[1])[:2]

    def __get_bottoms(self, polygon):
        return sorted(polygon, key=lambda p: p[1])[2:]

def py_init(width, height):
    init(width, height)

def py_decode(img, width, height):
    cdef array.array a = array.array('i', img)
    cdef int[:] ca = a
    cdef int* ptr = <int*> &ca[0]

    cdef int[:] arr = np.empty(271, dtype=np.int32)
    cdef int* out = &arr[0]
    decode(ptr, width, height, out)

    modified_list = [element for element in arr]
    total_qrs = modified_list[0]
    qrs_data = []
    for i in range(total_qrs):
        qr_array_start = 1 + i*9
        qr_array_end = 1 + (i + 1)*9
        qrs_data.append(QrDecodedData(modified_list[qr_array_start:qr_array_end]))
    
    return qrs_data

def py_destroy():
    destroy(0)
