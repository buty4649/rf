#include <stdlib.h>

#include <mruby.h>
#include <mruby/array.h>
#include <mruby/error.h>
#include <mruby/variable.h>

int main(int argc, char *argv[])
{
    mrb_state *mrb = mrb_open();
    mrb_value mrb_argv = mrb_ary_new_capa(mrb, argc);
    mrb_value program_name = mrb_str_new_cstr(mrb, argv[0]);
    int i;
    int return_value;

    mrb_define_global_const(mrb, "PROGRAM_NAME", program_name);
    mrb_gv_set(mrb, mrb_intern_lit(mrb, "$0"), program_name);

    for (i = 1; i < argc; i++)
    {
        mrb_ary_push(mrb, mrb_argv, mrb_str_new_cstr(mrb, argv[i]));
    }
    mrb_funcall(mrb, mrb_top_self(mrb), "__main__", 1, mrb_argv);

    return_value = EXIT_SUCCESS;

    if (mrb->exc)
    {
        if (!MRB_EXC_EXIT_P(mrb->exc))
        {
            mrb_print_error(mrb);
            return_value = EXIT_FAILURE;
        }
        else
        {
            // call SystemExit#status
            mrb_value exit_status = mrb_iv_get(mrb, mrb_obj_value(mrb->exc), mrb_intern_lit(mrb, "status"));
            return_value = mrb_fixnum(exit_status);
        }
    }
    mrb_close(mrb);

    return return_value;
}
