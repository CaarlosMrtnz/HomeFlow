-- Trigger para la creación de perfiles (Auth)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_new_user();

-- Trigger para las anomalías en lecturas (Public)
DROP TRIGGER IF EXISTS trigger_check_reading_anomalies ON public.readings;
CREATE TRIGGER trigger_check_reading_anomalies
    AFTER INSERT ON public.readings
    FOR EACH ROW
    EXECUTE FUNCTION public.check_reading_anomalies();