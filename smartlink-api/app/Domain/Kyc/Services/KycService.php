<?php

namespace App\Domain\Kyc\Services;

use App\Domain\Kyc\Enums\KycStatus;
use App\Domain\Kyc\Enums\KycType;
use App\Domain\Kyc\Models\KycDocument;
use App\Domain\Kyc\Models\KycRequest;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Riders\Models\RiderProfile;
use App\Domain\Shops\Models\SellerBankAccount;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class KycService
{
    /**
     * @param  list<UploadedFile>  $documents
     * @param  list<string>  $docTypes
     */
    public function submit(User $user, KycType $type, array $meta, array $documents = [], array $docTypes = []): KycRequest
    {
        return DB::transaction(function () use ($user, $type, $meta, $documents, $docTypes) {
            if (in_array($type, [KycType::Seller, KycType::Rider], true)) {
                $operationalZoneId = UserZone::query()
                    ->where('user_id', $user->id)
                    ->where('type', 'operational')
                    ->value('zone_id');

                if (! $operationalZoneId) {
                    throw new \RuntimeException('Operational zone is required.');
                }
            }

            $kyc = KycRequest::create([
                'user_id' => $user->id,
                'kyc_type' => $type,
                'status' => KycStatus::Pending,
                'submitted_at' => now(),
                'reviewed_by' => null,
                'reviewed_at' => null,
                'rejection_reason' => null,
                'meta_json' => $meta === [] ? null : $meta,
            ]);

            if ($type === KycType::Seller) {
                SellerBankAccount::updateOrCreate(
                    ['seller_user_id' => $user->id],
                    [
                        'bank_name' => (string) ($meta['bank_name'] ?? ''),
                        'account_number' => (string) ($meta['account_number'] ?? ''),
                        'account_name' => (string) ($meta['account_name'] ?? ''),
                        'verified_at' => null,
                    ],
                );
            }

            if ($type === KycType::Rider) {
                $profile = RiderProfile::query()->where('rider_user_id', $user->id)->first();
                if (! $profile) {
                    $profile = new RiderProfile(['rider_user_id' => $user->id, 'qr_code_token' => Str::uuid()->toString()]);
                }

                $profile->forceFill([
                    'vehicle_type' => (string) ($meta['vehicle_type'] ?? 'bike'),
                    'plate_number' => $meta['plate_number'] ?? null,
                ])->save();

                RiderAvailability::firstOrCreate(
                    ['rider_user_id' => $user->id],
                    ['status' => 'offline', 'last_seen_at' => now()],
                );
            }

            $disk = (string) config('smartlink.media_disk', 'local');
            foreach ($documents as $i => $file) {
                $path = Storage::disk($disk)->putFileAs(
                    "kyc/{$user->id}/{$kyc->id}",
                    $file,
                    Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
                );

                KycDocument::create([
                    'kyc_request_id' => $kyc->id,
                    'doc_type' => $docTypes[$i] ?? 'document',
                    'file_url' => Storage::disk($disk)->url($path),
                ]);
            }

            // Keep sellers/riders pending until admin approval.
            if ($user->status !== UserStatus::Pending) {
                $user->forceFill(['status' => UserStatus::Pending])->save();
            }

            return $kyc->fresh(['documents']);
        });
    }
}
